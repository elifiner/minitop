import Cocoa
import WebKit
import Foundation

let KEEP_URL = "https://keep.google.com"

struct AppSettings: Codable {
    var lastURL: String
    var recentURLs: [String]
    var stayOnTop: Bool
    var mobileMode: Bool
    
    init() {
        lastURL = KEEP_URL
        recentURLs = [KEEP_URL]
        stayOnTop = false
        mobileMode = true
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {
    var window: NSWindow!
    var webView: WKWebView!
    var settings: AppSettings = AppSettings()
    var settingsURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("MiniTop")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir.appendingPathComponent("settings.json")
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        loadSettings()
        setupWindow()
        setupMenu()
        setupWebView()
        loadURL(settings.lastURL)
        updateStayOnTopMenuItem()
        updateMobileModeMenuItem()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        saveSettings()
    }
    
    private func setupWindow() {
        window = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "MiniTop"
        updateWindowLevel()
        window.makeKeyAndOrderFront(nil)
        window.center()
    }
    
    private func setupMenu() {
        let mainMenu = NSMenu()
        
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        
        appMenu.addItem(NSMenuItem(title: "Set URL...", action: #selector(setURL), keyEquivalent: "u"))
        
        let recentMenu = NSMenu()
        let recentMenuItem = NSMenuItem(title: "Recent URLs", action: nil, keyEquivalent: "")
        recentMenuItem.submenu = recentMenu
        appMenu.addItem(recentMenuItem)
        updateRecentMenu()
        
        appMenu.addItem(NSMenuItem.separator())
        
        let stayOnTopItem = NSMenuItem(title: "Stay On Top", action: #selector(toggleStayOnTop), keyEquivalent: "t")
        appMenu.addItem(stayOnTopItem)
        
        let mobileItem = NSMenuItem(title: "Mobile Mode", action: #selector(toggleMobileMode), keyEquivalent: "m")
        appMenu.addItem(mobileItem)
        
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        NSApp.mainMenu = mainMenu
    }
    
    private func updateRecentMenu() {
        guard let recentMenuItem = NSApp.mainMenu?.item(at: 0)?.submenu?.item(withTitle: "Recent URLs"),
              let recentMenu = recentMenuItem.submenu else { return }
        
        recentMenu.removeAllItems()
        
        for url in settings.recentURLs {
            let item = NSMenuItem(title: url, action: #selector(loadRecentURL(_:)), keyEquivalent: "")
            item.representedObject = url
            recentMenu.addItem(item)
        }
    }
    
    @objc private func setURL() {
        let alert = NSAlert()
        alert.messageText = "Set URL"
        alert.informativeText = "Enter the URL to load:"
        alert.addButton(withTitle: "Load")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        input.stringValue = webView.url?.absoluteString ?? settings.lastURL
        alert.accessoryView = input
        
        input.selectText(nil)
        
        if alert.runModal() == .alertFirstButtonReturn {
            let urlString = input.stringValue
            if !urlString.isEmpty {
                loadURL(urlString)
            }
        }
    }
    
    @objc private func loadRecentURL(_ sender: NSMenuItem) {
        if let url = sender.representedObject as? String {
            loadURL(url)
        }
    }
    
    @objc private func toggleStayOnTop() {
        settings.stayOnTop.toggle()
        updateWindowLevel()
        updateStayOnTopMenuItem()
    }
    
    @objc private func toggleMobileMode() {
        settings.mobileMode.toggle()
        updateUserAgent()
        updateMobileModeMenuItem()
        webView.reload()
    }
    
    private func updateWindowLevel() {
        window.level = settings.stayOnTop ? .floating : .normal
    }
    
    private func updateStayOnTopMenuItem() {
        guard let stayOnTopItem = NSApp.mainMenu?.item(at: 0)?.submenu?.item(withTitle: "Stay On Top") else { return }
        stayOnTopItem.state = settings.stayOnTop ? .on : .off
    }
    
    private func updateMobileModeMenuItem() {
        guard let mobileItem = NSApp.mainMenu?.item(at: 0)?.submenu?.item(withTitle: "Mobile Mode") else { return }
        mobileItem.state = settings.mobileMode ? .on : .off
    }
    
    private func updateUserAgent() {
        let userAgent = settings.mobileMode ? 
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1" :
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        webView.customUserAgent = userAgent
    }
    
    private func setupWebView() {
        webView = WKWebView(frame: window.contentView!.bounds)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        updateUserAgent()
        window.contentView!.addSubview(webView)
    }
    
    private func loadURL(_ urlString: String) {
        var finalURL = urlString
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            finalURL = "https://" + urlString
        }
        
        if let url = URL(string: finalURL) {
            webView.load(URLRequest(url: url))
        }
    }
    
    private func addToRecent(_ url: String) {
        guard let urlObj = URL(string: url), let host = urlObj.host else { return }
        
        let baseURL = "\(urlObj.scheme ?? "https")://\(host)"
        
        settings.recentURLs.removeAll { 
            guard let existingURL = URL(string: $0), let existingHost = existingURL.host else { return false }
            return existingHost == host
        }
        settings.recentURLs.insert(baseURL, at: 0)
        settings.recentURLs = Array(settings.recentURLs.prefix(10))
        updateRecentMenu()
    }
    
    private func loadSettings() {
        if let data = try? Data(contentsOf: settingsURL),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
    
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            try? encoded.write(to: settingsURL)
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url?.absoluteString {
            addToRecent(url)
            settings.lastURL = url
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showErrorAlert(error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showErrorAlert(error)
    }
    
    private func showErrorAlert(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Failed to Load URL"
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run() 