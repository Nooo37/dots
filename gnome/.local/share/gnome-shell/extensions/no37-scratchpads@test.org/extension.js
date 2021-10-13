/* extension.js
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

/* exported init */

const MAPPINGS_FAST = [
    { app: 'Brave',    binding: '<super>f', cmd: ['brave'] },
    { app: 'WezTerm',  binding: '<super>t', cmd: ['wezterm'] }
];

const MAPPINGS_SCRATCHPAD = [
    { app: 'Discord',  binding: '<super>d', cmd: ['flatpak', 'run', 'com.discordapp.Discord'], width: 1500, height: 1000 },
    { app: 'Lollypop', binding: '<super>g', cmd: ['lollypop'], x: ((1920 - 1000) / 2), y: (1080 - 500 - 20), width: 1000, height: 500 },
];

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const KeyBinder = Me.imports.keybinder.KeyBinder;
const Shell = imports.gi.Shell;
const Util = imports.misc.util;

class Extension {
  constructor() {
    log('constructing fast focus extension');

    this.appSystem = Shell.AppSystem.get_default();
    this.keyBinder = new KeyBinder();
  }

  enable() {
    for (const mapping of MAPPINGS_FAST) {
      this.keyBinder.listenFor(mapping.binding, () => {
        this.activateApp(mapping);
      });
    }
    for (const mapping of MAPPINGS_SCRATCHPAD) {
      this.keyBinder.listenFor(mapping.binding, () => {
        this.toggleWindow(mapping);
      });
    }
  }

  disable() {
    this.keyBinder.clearBindings();
  }

  activateApp(mapping) {
    const app = this.appSystem
      .get_running()
      .find(app => app.get_name() === mapping.app);

    if (app === undefined) {
      Util.spawn(mapping.cmd);
    } else {
      app.activate();
    }
  }

  toggleWindow(mapping) {
    // let win = this.findWindow(name);
    let wins = [];
    this.appSystem
      .get_running()
      .filter(app => app.get_name() === mapping.app)
      .map(app => wins.push(...app.get_windows()));

    if (!wins.length) {
      Util.spawn(mapping.cmd);
      return;
    }
    wins.forEach(win => {
      if (win === undefined) { 
        return;
      }

      if (win.has_focus()) {
        this.hideWindow(win);
      } else {
        if (mapping.x === undefined || mapping.y === undefined) {
          win.move_resize_frame(true, 0, 0, mapping.width, mapping.height);
          this.centerWindow(win);
        } else {
          win.move_resize_frame(true, mapping.x, mapping.y, mapping.width, mapping.height);
        }
        this.showWindow(win);
      }
    });
  }

  findWindow(name) {
    let windows = [];
    this.appSystem.get_running().map(app => windows.push(...app.get_windows()));

    const win = windows.find(win => {
      return win.get_title() === name || win.get_wm_class_instance() === name
    });

    if (win === undefined) {
      log(`Couldn't locate "${name}" window`);
      log(`Found these other windows:`);
      this.logWindows();
    }

    return win;
  }

  logWindows() {
    for (const app of this.appSystem.get_running()) {
      for (const win of app.get_windows()) {
        log(`=========================`);
        log(`title: "${win.get_title()}"`);
        log(`class instance: "${win.get_wm_class_instance()}"`);
      }
    }
  }

  showWindow(win) {
    win.change_workspace_by_index(
      global.workspace_manager.get_active_workspace_index(),
      false
    );
    win.unminimize();
    win.raise();
    win.focus(0);
  }

  hideWindow(win) {
    win.minimize();
  }
    
  centerWindow(win) {
    // Get the dimensions of the window.
    const { width: windowWidth, height: windowHeight } = win.get_frame_rect();

    // Get the dimensions of the primary display and its position
    // relative to the workspace (which includes all monitors).
    const workspace = global.workspace_manager.get_active_workspace();
    const display = workspace.get_display();
    const primaryMonitorIndex = display.get_primary_monitor();
    const {
      width: monitorWidth,
      height: monitorHeight
    } = workspace.get_work_area_for_monitor(primaryMonitorIndex);
    const {
      x: monitorX,
      y: monitorY
    } = display.get_monitor_geometry(primaryMonitorIndex);

    // Establish the coordinates required to center the window on the
    // primary monitor, accounting for its position in the workspace.
    const x = monitorWidth / 2 - windowWidth / 2 + monitorX;
    const y = monitorHeight / 2 - windowHeight / 2 + monitorY;

    // Center the window, specifying this as a user-driven operation.
    win.move_frame(true, x, y);
  }
}

function init() {
  return new Extension();
}
