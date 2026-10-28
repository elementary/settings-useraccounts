/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2026 elementary, Inc. (https://elementary.io)
 */

public class SwitchboardPlugUserAccounts.Widgets.UserItem : Gtk.ListBoxRow {
    private Gtk.Revealer description_revealer;
    private Adw.Avatar avatar;
    private Granite.HeaderLabel full_name_label;
    private Gtk.Revealer lock_revealer;

    public weak Act.User user { get; construct; }

    public UserItem (Act.User user) {
        Object (user: user);
    }

    construct {
        full_name_label = new Granite.HeaderLabel ("") {
            size = H3
        };

        avatar = new Adw.Avatar (32, user.real_name, true);

        var lock_image = new Gtk.Image.from_icon_name ("locked") {
            halign = END,
            valign = END,
            pixel_size = 16
        };

        lock_revealer = new Gtk.Revealer () {
            child = lock_image,
            transition_type = CROSSFADE
        };

        var overlay = new Gtk.Overlay () {
            child = avatar
        };
        overlay.add_overlay (lock_revealer);

        var box = new Granite.Box (HORIZONTAL, NONE);
        box.append (overlay);
        box.append (full_name_label);

        update ();

        child = box;

        // Need to make a weak signal connection for automatic disconnection when finalised
        // Otherwise UserItem is never destroyed (memory leak)
        unowned UserItem weak_this = this;
        user.changed.connect (weak_this.update);
    }

    private void update () {
        var user_icon_file = File.new_for_path (user.get_icon_file ());
        try {
            avatar.custom_image = Gdk.Texture.from_file (user_icon_file );
        } catch (Error e) {
            avatar.custom_image = null;
        }

        full_name_label.label = user.real_name;
        avatar.text = user.real_name;
        lock_revealer.reveal_child = user.locked;
        full_name_label.secondary_text = user.user_name;

        if (user.account_type == Act.UserAccountType.ADMINISTRATOR) {
            full_name_label.secondary_text += " (%s)".printf (_("Administrator"));
        }
    }
}
