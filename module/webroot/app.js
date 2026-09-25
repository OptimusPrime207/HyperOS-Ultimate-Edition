"use strict";

const HUE = {
    state: {
        gaming: false,
        battery: false,
        smoothness: true,
        temperature: null,
        batteryLevel: null,
        thermalStatus: "Waiting for module backend",
        device: "Detecting...",
        codename: "Detecting...",
        kernel: "Detecting..."
    },

    elements: {},

    init() {
        this.elements = {
            temperature: document.getElementById("temperature"),
            battery: document.getElementById("battery"),
            gaming: document.getElementById("gaming"),
            thermalStatus: document.getElementById("thermalStatus"),

            device: document.getElementById("device"),
            codename: document.getElementById("codename"),
            kernel: document.getElementById("kernel"),

            gamingSwitch: document.getElementById("gamingSwitch"),
            batterySwitch: document.getElementById("batterySwitch"),
            smoothSwitch: document.getElementById("smoothSwitch")
        };

        this.restoreState();
        this.render();
    },

    toggle(mode) {
        if (mode === "gaming") {
            this.state.gaming = !this.state.gaming;
        }

        if (mode === "battery") {
            this.state.battery = !this.state.battery;
        }

        if (mode === "smoothness") {
            this.state.smoothness = !this.state.smoothness;
        }

        this.saveState();
        this.render();
    },

    saveState() {
        try {
            localStorage.setItem(
                "hue-ui-state",
                JSON.stringify({
                    gaming: this.state.gaming,
                    battery: this.state.battery,
                    smoothness: this.state.smoothness
                })
            );
        } catch (e) {
            // Storage may be unavailable in some WebView environments.
        }
    },

    restoreState() {
        try {
            const saved = localStorage.getItem("hue-ui-state");

            if (!saved) {
                return;
            }

            const data = JSON.parse(saved);

            if (typeof data.gaming === "boolean") {
                this.state.gaming = data.gaming;
            }

            if (typeof data.battery === "boolean") {
                this.state.battery = data.battery;
            }

            if (typeof data.smoothness === "boolean") {
                this.state.smoothness = data.smoothness;
            }
        } catch (e) {
            // Ignore invalid or unavailable local storage.
        }
    },

    setSwitch(element, active) {
        if (!element) {
            return;
        }

        element.classList.toggle("active", active);
        element.setAttribute("aria-pressed", active ? "true" : "false");
    },

    render() {
        const s = this.state;
        const e = this.elements;

        if (e.temperature) {
            e.temperature.textContent =
                s.temperature === null ? "--°C" : `${s.temperature}°C`;
        }

        if (e.battery) {
            e.battery.textContent =
                s.batteryLevel === null ? "--%" : `${s.batteryLevel}%`;
        }

        if (e.gaming) {
            e.gaming.textContent = s.gaming ? "ON" : "OFF";
        }

        if (e.thermalStatus) {
            e.thermalStatus.textContent = s.thermalStatus;
        }

        if (e.device) {
            e.device.textContent = s.device;
        }

        if (e.codename) {
            e.codename.textContent = s.codename;
        }

        if (e.kernel) {
            e.kernel.textContent = s.kernel;
        }

        this.setSwitch(e.gamingSwitch, s.gaming);
        this.setSwitch(e.batterySwitch, s.battery);
        this.setSwitch(e.smoothSwitch, s.smoothness);
    },

    /*
     * Backend API placeholder.
     *
     * Later this function will receive real information from
     * the HyperOS Ultimate Edition module.
     *
     * No direct kernel interface is accessed from this UI.
     */
    updateBackendData(data) {
        if (!data || typeof data !== "object") {
            return;
        }

        if (typeof data.temperature === "number") {
            this.state.temperature = data.temperature;
        }

        if (typeof data.battery === "number") {
            this.state.batteryLevel = data.battery;
        }

        if (typeof data.thermalStatus === "string") {
            this.state.thermalStatus = data.thermalStatus;
        }

        if (typeof data.device === "string") {
            this.state.device = data.device;
        }

        if (typeof data.codename === "string") {
            this.state.codename = data.codename;
        }

        if (typeof data.kernel === "string") {
            this.state.kernel = data.kernel;
        }

        this.render();
    }
};

function toggleGaming() {
    HUE.toggle("gaming");
}

function toggleBattery() {
    HUE.toggle("battery");
}

function toggleSmoothness() {
    HUE.toggle("smoothness");
}

document.addEventListener("DOMContentLoaded", () => {
    HUE.init();
});
