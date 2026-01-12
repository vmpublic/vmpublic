/****************************************************************************		
* PRIVACY	
****************************************************************************/		

/* Fingerprinting protection */		
user_pref("privacy.fingerprintingProtection", true);		
		
/* Tracking protection */		
user_pref("privacy.trackingprotection.enabled", true);		
/* COMMENTED OUT BUT KEEPING FOR POSTERITY */ /* user_pref("browser.privatebrowsing.autostart", true); */		
		
/* Disable telemetry */		
user_pref("toolkit.telemetry.enabled", false);		
user_pref("toolkit.telemetry.unified", false);		
		
/* Disable data reporting */		
user_pref("datareporting.policy.dataSubmissionEnabled", false);		
		
/* Disable studies and experiments */		
user_pref("app.shield.optoutstudies.enabled", false);		
user_pref("app.normandy.enabled", false);		
		
/* Disable auto-fill rubbish */		
	/* Disable saving passwords */	
		user_pref("signon.rememberSignons", false);
	/* Disable autofill for logins */	
		user_pref("signon.autofillForms", false);
	/* Disable asking to save passwords after form submissions */	
		user_pref("signon.formlessCapture.enabled", false);
	/* Disable credit card autofill (related to form data saving) */	
		user_pref("extensions.formautofill.creditCards.enabled", false);
	/* Disable address autofill (if you want no autofill of any personal data) */	
		user_pref("extensions.formautofill.addresses.enabled", false);
		
/* Disable WebRTC (leaks local IP addresses) */		
user_pref("media.peerconnection.enabled", false);		
		
/* Disable geolocation */		
user_pref("geo.enabled", false);		
		
/* Restrict referrer information */		
user_pref("network.http.referer.XOriginPolicy", 2);		
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);		
		
/* Cookie behaviour (1 = block third-party cookies) */		
user_pref("network.cookie.cookieBehavior", 5);		
		
/* DNS-over-HTTPS (DoH) settings */		
	/* Strict DoH only */	
		user_pref("network.trr.mode", 3);
	/* DoH server */	
		user_pref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");
	/* Disable DNS prefetching */	
		user_pref("network.dns.disablePrefetch", true);
	/* Disable link prefetching  */	
		user_pref("network.prefetch-next", false);
	/* Disable speculative pre-connections  */	
		user_pref("network.predictor.enabled", false);
		
/****************************************************************************		
* SECURITY	
****************************************************************************/		
		
/* Enable HTTPS-only mode */		
user_pref("dom.security.https_only_mode", true);		
		
/* Disable insecure renegotiation in TLS */		
user_pref("security.ssl.require_safe_negotiation", true);		
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);		
		
/****************************************************************************		
* INTERFACE		
****************************************************************************/		
		
/* Disable search engine suggestions (ALREADY HANDLED BY USERCHROME.CSS BUT ALSO INCLUDING THIS VERSION FOR POSTERITY) */		
user_pref("browser.search.suggest.enabled", false);		
user_pref("browser.urlbar.suggest.searches", false);

/* Disable checkDefaultBrowser */
user_pref("browser.shell.checkDefaultBrowser", false);
		
/* Always ask where to save files */		
user_pref("browser.download.useDownloadDir", false);		
		
/* Enable access to Browser Toolbox */		
user_pref("devtools.chrome.enabled", true);		
user_pref("devtools.debugger.remote-enabled", true);		
		
/* Set custom homepage */		
/* COMMENTED OUT BUT KEEPING FOR POSTERITY */ /* user_pref("browser.startup.homepage", "https://bensawesomeexamplewebsite.com"); */		
		
/* Dark mode - tested 29-04-2025 - successfully applies to UI and to backgrounds for Firefox's about pages, and on Google, Youtube, ChatGPT, GitHub, BUT not for Wikipedia */		
user_pref("ui.systemUsesDarkTheme", 1);		
		
/* Enable stylesheets for further customisation via userchrome.css and usercontent.css */		
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);		
