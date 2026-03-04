// ── Project store (signal-based) ─────────────────────────────
//
// Single source of truth for project data and sidebar filter state.

import { signal } from "@preact/signals";
import { sendRpc } from "../helpers.js";

// ── Signals ──────────────────────────────────────────────────
export var projects = signal([]);
export var activeProjectId = signal(localStorage.getItem("leetium-project") || "");
export var projectFilterId = signal(localStorage.getItem("leetium-project-filter") || "");

// ── Methods ──────────────────────────────────────────────────

/** Replace the full project list (e.g. after fetch or bootstrap). */
export function setAll(arr) {
	projects.value = arr || [];
}

/** Fetch projects from the server via RPC. */
export function fetch() {
	return sendRpc("projects.list", {}).then((res) => {
		if (!res?.ok) return;
		setAll(res.payload || []);
	});
}

/** Set the active project id (bound to the active session's project). */
export function setActiveProjectId(id) {
	activeProjectId.value = id || "";
}

/** Set the sidebar filter project id. Persists to localStorage. */
export function setFilterId(id) {
	projectFilterId.value = id || "";
	if (id) {
		localStorage.setItem("leetium-project-filter", id);
	} else {
		localStorage.removeItem("leetium-project-filter");
	}
}

/** Look up a project by id. */
export function getById(id) {
	return projects.value.find((p) => p.id === id) || null;
}

export var projectStore = {
	projects,
	activeProjectId,
	projectFilterId,
	setAll,
	fetch,
	setActiveProjectId,
	setFilterId,
	getById,
};
