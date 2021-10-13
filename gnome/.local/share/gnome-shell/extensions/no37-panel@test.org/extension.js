const Main = imports.ui.main;
const Mainloop = imports.mainloop;
const WorkspaceThumbnail = imports.ui.workspaceThumbnail;
const ExtensionUtils = imports.misc.extensionUtils;
const Background = imports.ui.background;


const {GLib, Clutter, St, GObject, Meta} = imports.gi;

let panelButton, panelButtonText, timeout;
let panel;
let barHeight = 2;
let updateInterval = 30;
let oneBitWidth = 30;
let oneTimeBitWidth = oneBitWidth;
let oneTimeSepWidth = 2;


const WINDOW_PREVIEW_SIZE = 400;

var WorkspaceIcon = GObject.registerClass(
class WorkspaceIcon extends St.BoxLayout {
    _init(workspace_index) {
        super._init({ style_class: 'alt-tab-app',
                      vertical: true });

        this.metaWorkspace = global.workspace_manager.get_workspace_by_index(workspace_index);

        this.connect('destroy', this._onDestroy.bind(this));

        //let settings = ExtensionUtils.getSettings(SCHEMA_NAME);
        //let workspaceName = workspace.workspaceName[workspace_index + 1];
        //if (workspaceName == null || workspaceName == '')
        //    workspaceName = "Workspace" + " " + String(workspace_index + 1);
        this.label = new St.Label({ text: "heyho" });

        this._icon = new St.Widget({ layout_manager: new Clutter.BinLayout() });
        this._icon.destroy_all_children();
        this.add_actor(this._icon);

        let workArea = Main.layoutManager.getWorkAreaForMonitor(Main.layoutManager.primaryIndex);
        this._porthole = { width: workArea.width,
                           height: workArea.height,
                           x: workArea.x,
                           y: workArea.y };

        let scaleFactor = St.ThemeContext.get_for_stage(global.stage).scale_factor;
        let windowSize = WINDOW_PREVIEW_SIZE * scaleFactor;
        this.scale = Math.min(1.0, windowSize / this._porthole.width,
                                   windowSize / this._porthole.height);

        this._createBackground(Main.layoutManager.primaryIndex);

        this._createWindowThumbnail();

        this._icon.add_actor(this._createNumberIcon(workspace_index + 1));
        this._icon.set_size(windowSize, windowSize * (this._porthole.height / this._porthole.width));
    }

    _createWindowThumbnail() {
        this._windowsThumbnail = new St.Widget({ 
            x_expand: true,
            y_expand: true,
            y_align:  Clutter.ActorAlign.CENTER });

        let windows = global.get_window_actors().filter(actor => {
            let win = actor.meta_window;
            return win.located_on_workspace(this.metaWorkspace);
        });

        for (let i = 0; i < windows.length; i++) {
            if (this._isMyWindow(windows[i])) {
                let clone = new WorkspaceThumbnail.WindowClone(windows[i]);
                this._windowsThumbnail.add_actor(clone);
            }
        }

        this._windowsThumbnail.set_size(this._porthole.width * this.scale,
                                        this._porthole.height * this.scale);
        this._windowsThumbnail.set_scale(this.scale, this.scale);
        this._icon.add_actor(this._windowsThumbnail);
    }

    _isMyWindow(actor) {
        let win = actor.meta_window;
        return win.located_on_workspace(this.metaWorkspace) &&
            (win.get_monitor() == Main.layoutManager.primaryIndex);
    }

    _createBackground(index) {
        this._backgroundGroup = new Clutter.Actor({
            layout_manager: new Clutter.BinLayout(),
            x_expand: true,
            y_expand: true,
        });
        this._icon.add_child(this._backgroundGroup);

        this._bgManager = new Background.BackgroundManager({
            container: this._backgroundGroup,
            monitorIndex: index,
            controlPosition: false,
        });
    }

    _createNumberIcon(number) {
        let icon = new St.Widget({ x_expand: true,
                                   y_expand: true,
                                   x_align:  Clutter.ActorAlign.END,
                                   y_align:  Clutter.ActorAlign.END });

        let box = new St.BoxLayout({ style_class: 'number-window',
                                     vertical: true });
        icon.add_actor(box);

        let label = new St.Label({ style_class: 'number-label',
                                   text: number.toString() });
        box.add(label);

        return icon;
    }

    _onDestroy() {
        if (this._bgManager) {
            this._bgManager.destroy();
            this._bgManager = null;
        }
    }
});


function getWorkspaceManager() {
    return global.screen || global.workspace_manager;
}

const PanelEntry = GObject.registerClass(
class PanelEntry extends St.BoxLayout {
    _init(args) {
        super._init({
            vertical : false,
            pack_start : false, // packing from the left is more intuitive
            clip_to_allocation : true,
            style_class : args.style || "secondary-bg",
            reactive : true,
            can_focus : true,
            track_hover : true,
            height : barHeight,
            width : args.width || 400,
        });
    }
});

const SimpleButton = GObject.registerClass(
class SimpleButton extends PanelEntry {
    _init(args) {
        super._init(args);
    }
});

const SimpleSlider = GObject.registerClass(
class SimpleSlider extends PanelEntry {
    sliderin;
    fraction;
    _init(args) {
        let style = args.style || "bg-a";
        args.style = undefined;
        super._init(args);
        this.fraction = args.fraction || 0.5;
        this.sliderin = new St.Bin({
            style_class : style,
            reactive : true,
            can_focus : true,
            track_hover : true,
            height : barHeight,
            width : this.width * this.fraction,
        });
        this.add_child(this.sliderin);
    }

    set_fraction(new_fraction, animate) {
        // limit between 0 and 1
        this.fraction = new_fraction > 1 ? 1 : (new_fraction < 0 ? 0 : new_fraction);
        if (animate) {
            this.sliderin.ease({
                width: this.fraction * this.width,
                duration: 300,
                mode: Clutter.AnimationMode.EASE_OUT,
            });
        } else {
            this.sliderin.width = this.fraction * this.width;
        }
    }
});

const VolumeSlider = GObject.registerClass(
class VolumeSlider extends SimpleSlider {
    _init(args) {
        super._init(args);
        let DELTA_SCROLL = 0.05;

        this.connect("scroll-event", (actor, event) => {
            let direction = event.get_scroll_direction();
            if (direction == Clutter.ScrollDirection.DOWN) {
                this.set_fraction(this.fraction - DELTA_SCROLL, true);
            } else if (direction == Clutter.ScrollDirection.UP) {
                this.set_fraction(this.fraction + DELTA_SCROLL, true);
            }
        });

        this.connect("button-press-event", (actor, event) => {
            log("press");
        });

        this.connect("button-release-event", (actor, event) => {
            log("release");
        });
    }
});

const FancyWorkspaceIndicator = GObject.registerClass(
class FancyWorkspaceIndicator extends PanelEntry {
    workspaceManager;
    indicators;
    timeout;
    popup;

    updateIndicators() {
        log("up");
        this.destroy_all_children();
        this.remove_all_children();
        let numWorkspaces = this.workspaceManager.get_n_workspaces();
        let focusedWorkspace = this.workspaceManager.get_active_workspace_index();
        //for (let i = 0; i < numWorkspaces; i++) {
        //    this.indicators[i].style_class = "secondary-bg";
        //}
        let bit_opts = { style : "secondary-bg", width : oneBitWidth };
        let sep_opts = { width : this.oneSepWidth, style : "bg-color" };
        this.indicators = [];
        this.indicators[0] = new SimpleButton(bit_opts);
        this.indicators[0].connect("enter-event", () => {
            // this.popup.show()
            // this.popup.set_child(new WorkspaceIcon(0));
        });
        this.indicators[0].connect("leave-event", () => {
            // this.popup.hide();
        });
        this.add_child(this.indicators[0]);
        log("h: ", numWorkspaces);
        for (let i = 1; i < numWorkspaces; i++) {
            let workspace = this.workspaceManager.get_workspace_by_index(i);
            log("W; ", i);
            this.indicators[i] = new SimpleButton(bit_opts);
            this.indicators[i].connect("enter-event", () => {
                // this.popup.show();
                // this.popup.set_child(new WorkspaceIcon(i));
            });
            this.indicators[i].connect("leave-event", () => {
                // this.popup.hide();
            });
            this.indicators[i].connect("button-release-event", () => {
                log("test");
                workspace.activate_with_focus(0, null);
            });
            this.add_child(getSeperator(sep_opts));
            this.add_child(this.indicators[i]);
        }
        this.indicators[focusedWorkspace].style_class = "blue-bg";
        return true;
    }

    _init(args) {
        // init popup
        //this.popup = new St.Bin({
        //    style_class : "ws-popup",
        //    reactive : true,
        //    can_focus : true,
        //    track_hover : true,
        //});
        //this.popup.set_position(10, 10);
        //Main.layoutManager.addChrome(this.popup, {
        //   affectsInputRegion : true,
        //   trackFullscreen : true,
        //});
        // init indicators
        this.workspaceManager = getWorkspaceManager();
        this.oneSepWidth = oneTimeSepWidth;
        let numSeps = 3;
        let numBits = 4;
        args.width = oneBitWidth * numBits + this.oneSepWidth * numSeps;
        super._init(args);
        let numWorkspaces = this.workspaceManager.get_n_workspaces();
        let focusedWorkspace = this.workspaceManager.get_active_workspace_index();
        this.workspaceManager.connect("active-workspace-changed", () => {
            this.updateIndicators();
        });
        this.workspaceManager.connect("workspace-added", (actor, num) => {
            log("test", num)
            this.updateIndicators();
        });
        this.workspaceManager.connect("workspace-removed", () => {
            this.updateIndicators();
        });
    }
});

const WorkspaceIndicator = GObject.registerClass(
class WorkspaceIndicator extends PanelEntry {
    numWorkspaces;
    focusedWorkspace;
    highlighter;
    oneWidth;
    workspaceManager;

    updateWorkspaceNums() {
        this.numWorkspaces = this.workspaceManager.get_n_workspaces();
        //this.width = this.oneWidth * this.numWorkspaces;
        this.ease({ 
            width: this.oneWidth * this.numWorkspaces,
            duration: 300,
            mode: Clutter.AnimationMode.EASE_OUT,
        });
    }

    updateWorkspaceActive() {
        this.focusedWorkspace = this.workspaceManager.get_active_workspace_index();
        this.highlighter.ease({ 
            margin_left : this.focusedWorkspace * this.oneWidth,
            duration: 300,
            mode: Clutter.AnimationMode.EASE_OUT,
        });
    }

    _init(args) {
        this.workspaceManager = getWorkspaceManager();
        this.oneWidth = args.width || 30;
        //args.style = "workspace-inactive";
        super._init(args);
        this.highlighter = new St.Bin({
            style_class : "workspace-highlighter",
            reactive : true,
            can_focus : true,
            track_hover : true,
            height : barHeight,
            width : this.oneWidth,
            x : 10
        });
        this.updateWorkspaceActive();
        this.updateWorkspaceNums();
        this.width = this.numWorkspaces * this.oneWidth;
        this.add_child(this.highlighter);
        this.workspaceManager.connect("active-workspace-changed", () => {
            this.updateWorkspaceActive();
        });
        this.workspaceManager.connect("workspace-added", () => {
            this.updateWorkspaceNums();
        });
        this.workspaceManager.connect("workspace-removed", () => {
            this.updateWorkspaceNums();
        });
        this.connect("enter-event", () => {
            log("enter");
        });
        this.connect("leave-event", () => {
            log("leave");
        });
    }
});


const CenterMenuButton = GObject.registerClass(
class CenterMenuButton extends SimpleButton {
    _init(args) {
        super._init(args);
        let x = 0;
        this.connect("button-release-event", () => {
            Main.panel.toggleCalendar();
        });
    }
});

const OverviewButton = GObject.registerClass(
class OverviewButton extends SimpleButton {
    _init(args) {
        super._init(args);
        this.connect("enter-event", () => {
            Main.overview.show();
        });
    }
});

const MenuButton = GObject.registerClass(
class MenuButton extends SimpleButton {
    _init(args) {
        super._init(args);
        this.connect("enter-event", () => {
            Main.panel.statusArea.aggregateMenu.menu.open();
        });
    }
});
function getSeperator(args) {
    return new PanelEntry({
        style : args.style || "bg-color",
        width : args.width || 20
    });
}

const HourIndicator = GObject.registerClass(
class HourIndicator extends PanelEntry {
    hourbits;
    timeout;

    update_time() {
        var now = GLib.DateTime.new_now_local();
        var hour = now.get_hour() % 12;
        var binString = "0000" + hour.toString(2);
        var len = binString.length;
        for (let i = 0; i < 4; i++) {
            this.hourbits[i].style_class = binString.charAt(len - (i + 1)) === "1" ? "time-bg" : "secondary-bg";
        }
        return true;
    }

    _init(args) {
        this.fraction = args.fraction || 0.5;
        //args.style = "bg-color";
        let numSeps = 3;
        let numBits = 4;
        //let oneBitWidth = oneTimeBitWidth;
        let oneSepWidth = oneTimeSepWidth;
        args.width = oneBitWidth * numBits + oneSepWidth * numSeps;
        super._init(args);
        let bit_opts = { style : "time-bg", width : oneBitWidth };
        this.hourbits = [];
        this.hourbits[0] = new SimpleButton(bit_opts);
        this.hourbits[1] = new SimpleButton(bit_opts);
        this.hourbits[2] = new SimpleButton(bit_opts);
        this.hourbits[3] = new SimpleButton(bit_opts);
        let sep_opts = { width : oneSepWidth, style : "bg-color" };
        this.add_child(this.hourbits[3]);
        this.add_child(getSeperator(sep_opts));
        this.add_child(this.hourbits[2]);
        this.add_child(getSeperator(sep_opts));
        this.add_child(this.hourbits[1]);
        this.add_child(getSeperator(sep_opts));
        this.add_child(this.hourbits[0]);
        this.update_time();
        this.timeout = Mainloop.timeout_add_seconds(updateInterval, () => {
            return this.update_time();
        })
    }
});

const MinuteIndicator = GObject.registerClass(
class MinuteIndicator extends SimpleSlider {
    timeout;
    update_time() {
        var now = GLib.DateTime.new_now_local();
        var minute = now.get_minute();
        this.set_fraction(minute / 60);
        return true;
    }

    _init(args) {
        super._init(args);
        this.update_time();
        this.timeout = Mainloop.timeout_add_seconds(updateInterval, () => {
            return this.update_time();
        })
    }
});

const FancyMinuteIndicator = GObject.registerClass(
class FancyMinuteIndicator extends PanelEntry {
    minutebits;
    timeout;

    update_time() {
        var now = GLib.DateTime.new_now_local();
        var minute = now.get_minute();
        var section = 60 / this.minutebits.length;
        for (let i = 0; i < 4; i++) {
            let fraction = (minute - section * i) / section;
            fraction = fraction < 0 ? 0 : fraction;
            fraction = fraction > 1 ? 1 : fraction;
            this.minutebits[i].set_fraction(fraction);
        }
        return true;
    }

    _init(args) {
        this.fraction = args.fraction || 0.5;
        //args.style = "bg-color";
        let numBits = 4;
        //let oneBitWidth = oneTimeBitWidth;
        let oneSepWidth = oneTimeSepWidth;
        args.width = oneBitWidth * numBits + oneSepWidth * (numBits - 1);
        super._init(args);
        let bit_opts = 
        this.minutebits = [];
        this.minutebits[0] = new SimpleSlider({ style : "time-bg", width : oneBitWidth });
        this.minutebits[1] = new SimpleSlider({ style : "time-bg", width : oneBitWidth });
        this.minutebits[2] = new SimpleSlider({ style : "time-bg", width : oneBitWidth });
        this.minutebits[3] = new SimpleSlider({ style : "time-bg", width : oneBitWidth });
        let sep_opts = { width : oneSepWidth, style : "bg-color" };
        this.add_child(this.minutebits[0]);
        this.add_child(getSeperator(sep_opts));
        this.add_child(this.minutebits[1]);
        this.add_child(getSeperator(sep_opts));
        this.add_child(this.minutebits[2]);
        this.add_child(getSeperator(sep_opts));
        this.add_child(this.minutebits[3]);
        this.update_time();
        this.timeout = Mainloop.timeout_add_seconds(updateInterval, () => {
            return this.update_time();
        })
    }
});


function init() {
    let pMonitor = Main.layoutManager.primaryMonitor;

    //let workspace = getWorkspaceManager().get_active_workspace();
    //let temp = new WorkspaceThumbnail.WorkspaceThumbnail(workspace, 0);
    //temp.setPorthole(100, 100, 100, 100);
    //temp.height = 100;
    //temp.set_label_actor(new St.Label({ text : "test" }))

    //wspopup.opacity = 0;

    panel = new St.Widget({
        style_class : "bg-color",
        reactive : true,
        can_focus : true,
        track_hover : true,
        height : barHeight,
        width : pMonitor.width,
        layout_manager: new Clutter.BinLayout(),
    })
    let leftBox = new St.BoxLayout({
        vertical : false,
        pack_start : true,
        clip_to_allocation : true,
        style_class : "bg-color",
        reactive : true,
        can_focus : true,
        track_hover : true,
        height : barHeight,
        x_expand: true,
        x_align: Clutter.ActorAlign.START,
    });
    let centerBox = new Clutter.Actor({
        layout_manager: new Clutter.BoxLayout({
                orientation: Clutter.Orientation.HORIZONTAL,
                pack_start: true,
        }),
        reactive : true,
    });
    let rightBox = new St.BoxLayout({
        vertical : false,
        pack_start : false, // packing from the left is more intuitive
        clip_to_allocation : true,
        style_class : "bg-color",
        reactive : true,
        can_focus : true,
        track_hover : true,
        height : barHeight,
        x_expand: true,
        x_align: Clutter.ActorAlign.END,
    });

    let thing = new VolumeSlider ({
        style : "bg-a",
        width : 100
    });
    let but = new FancyWorkspaceIndicator({});

    let cmb = new CenterMenuButton({
        style : "red-bg",
        width : oneBitWidth
    });
    let ovb = new OverviewButton({
        style : "blue-bg",
        width : oneBitWidth
    });
    let mb = new MenuButton({
        style : "violet-bg",
        width : oneBitWidth
    });

    let hourI = new HourIndicator({});
    let minuteI = new FancyMinuteIndicator({
        width : 100,
    });

    leftBox.add_child(thing);
    leftBox.add_child(getSeperator({}));
    leftBox.add_child(but);

    centerBox.add_child(minuteI);
    centerBox.add_child(getSeperator({}));
    centerBox.add_child(hourI);
    centerBox.connect("enter-event", () => {
        Main.panel.toggleCalendar();
    });
    centerBox.connect("leave-event", () => {
    });

    rightBox.add_child(getSeperator({}));
    rightBox.add_child(cmb);
    rightBox.add_child(getSeperator({}));
    rightBox.add_child(ovb);
    rightBox.add_child(getSeperator({}));
    rightBox.add_child(mb);
    rightBox.add_child(getSeperator({}));
    rightBox.set_x_expand(true);
    rightBox.set_x_align(Clutter.ActorAlign.END);

    panel.set_position(0, 0); //pMonitor.height - barHeight);

    panel.add_child(leftBox);
    panel.add_child(centerBox);
    panel.add_child(rightBox);
}

function enable() {
    Main.panel.height = 0;
    //Main.panel._rightBox.insert_child_at_index(panelButton, 1);
    Main.layoutManager.addChrome(panel, {
        affectsInputRegion : true,
        affectsStruts : false,
        trackFullscreen : true,
    })
}

function disable() {
    Main.panel.height = 30;
    //Mainloop.source_remove(timeout);
    //Main.panel._rightBox.remove_child(panelButton);
    Main.layoutManager.removeChrome(panel);
}

    //hourText = new St.Label({
    //    text: "37",
    //    x_align: Clutter.ActorAlign.CENTER,
    //    style_class: 'subtitle-2',
    //    // style: 'margin-bottom:5px',
    //});
    //minuteText = new St.Label({
    //    text: "37",
    //    x_align: Clutter.ActorAlign.CENTER,
    //    style_class: 'subtitle-2',
    //    style: 'margin-bottom:12px',
    //});

    //layout = new St.BoxLayout({
    //    vertical : true,
    //    width : 25,
    //    height : pMonitor.height,
    //    y_align: Clutter.ActorAlign.CENTER,
    //    y_expand : true,
    //    clip_to_allocation : true,
    //});


    //// top widgets
    //topBox = new St.BoxLayout({
    //    y_expand : true,
    //    vertical : true,
    //});
    //layout.add_child(topBox);

    //topBox.add_child(panelButtonText);

    //// bottom widgets
    //buttomBox = new Clutter.Actor({
    //    layout_manager: new Clutter.BoxLayout({
    //            orientation: Clutter.Orientation.HORIZONTAL,
    //            pack_start: true,
    //    }),
    //});
    //layout.add_child(buttomBox);
    //buttomBox.add_child(minuteText);
    //buttomBox.add_child(hourText);
