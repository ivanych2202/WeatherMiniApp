import UIKit
import WebKit

public class WeatherViewController: UIViewController {
    
    var weatherWebView: WKWebView!
    var loadingIndicator: UIActivityIndicatorView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let webConfiguration = WKWebViewConfiguration()
        weatherWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        weatherWebView.navigationDelegate = self
        weatherWebView.translatesAutoresizingMaskIntoConstraints = false
        weatherWebView.scrollView.isScrollEnabled = false
        view.addSubview(weatherWebView)
        
        loadingIndicator = UIActivityIndicatorView(style: .gray)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            weatherWebView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherWebView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            weatherWebView.widthAnchor.constraint(equalTo: view.widthAnchor),
            weatherWebView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        let backButton = UIButton(type: .system)
        backButton.setTitle("Назад", for: .normal)
        backButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        loadWeatherWidget()
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func loadWeatherWidget() {
        loadingIndicator.startAnimating()
        
        let htmlString = """
        <html>
        <head>
            <style>
                body { margin: 0; padding: 0; }
                #ww_656a21e50ae72_u { display: none !important; }
            </style>
        </head>
        <body>
            <div id="ww_656a21e50ae72" v='1.3' loc='auto' a='{"t":"horizontal","lang":"ru","ids":[],"font":"Arial","sl_ics":"one_a","sl_sot":"celsius","cl_bkg":"#FFFFFF","cl_font":"#000000","cl_cloud":"#d4d4d4","cl_persp":"#2196F3","cl_sun":"#FFC107","cl_moon":"#FFC107","cl_thund":"#FF5722","el_phw":3,"el_whr":3}'>
                <a href="https://weatherwidget.org/ru/" id="ww_656a21e50ae72_u" target="_blank">Бесплатный HTML погодный информер на сайт</a>
            </div>
            <script async src="https://app3.weatherwidget.org/js/?id=ww_656a21e50ae72"></script>
        </body>
        </html>
        """
        
        weatherWebView.loadHTMLString(htmlString, baseURL: nil)
    }
    
}

extension WeatherViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
        
        let jsString = """
        document.body.style.zoom = 2;
        document.body.style.overflow = 'hidden';
        """
        
        webView.evaluateJavaScript(jsString) { (result, error) in
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIndicator.startAnimating()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

