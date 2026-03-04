// Blocking theme init — prevents flash of wrong theme on share pages.
!(() => {
	var t = localStorage.getItem("leetium-theme") || "system";
	if (t === "system") t = matchMedia("(prefers-color-scheme:dark)").matches ? "dark" : "light";
	document.documentElement.setAttribute("data-theme", t);
})();
