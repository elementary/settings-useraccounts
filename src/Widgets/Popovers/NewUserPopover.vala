/*
* Copyright (c) 2014-2017 elementary LLC. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

namespace SwitchboardPlugUserAccounts.Widgets {
    public class NewUserPopover : Gtk.Popover {
        private Gtk.Grid grid;
        private Gtk.ComboBoxText        accounttype_combobox;
        private Gtk.Entry               fullname_entry;
        private Gtk.Entry               username_entry;
        private Gtk.Revealer            error_revealer;
        private Gtk.Label               error_label;

        private Gtk.Revealer            pw_revealer;
        private Widgets.PasswordEditor  pw_editor;

        private Gtk.Button              button_create;

        public signal void             request_user_creation 
            (string _fullname, string _username, Act.UserAccountType _usertype, 
            Act.UserPasswordMode _mode, string? _pw = null);

        public NewUserPopover (Gtk.Widget relative) {
            Object (
                position: Gtk.PositionType.BOTTOM,
                relative_to: relative
            );
        }

        construct {
            accounttype_combobox = new Gtk.ComboBoxText ();
            accounttype_combobox.set_size_request (200, 0);
            accounttype_combobox.halign = Gtk.Align.START;
            accounttype_combobox.append_text (_("Standard User"));
            accounttype_combobox.append_text (_("Administrator"));
            accounttype_combobox.set_active (0);

            fullname_entry = new Gtk.Entry ();
            fullname_entry.set_size_request (200, 0);
            fullname_entry.halign = Gtk.Align.START;
            fullname_entry.set_placeholder_text (_("Full Name"));
            fullname_entry.changed.connect (check_input);
            fullname_entry.changed.connect (() => 
                username_entry.set_text (gen_username (fullname_entry.get_text ())));

            username_entry = new Gtk.Entry ();
            username_entry.set_size_request (200, 0);
            username_entry.halign = Gtk.Align.START;
            username_entry.set_placeholder_text (_("Username"));
            username_entry.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,
                "dialog-information-symbolic");
            username_entry.set_icon_tooltip_text (Gtk.EntryIconPosition.SECONDARY,
                _("Can only contain lower case letters, numbers and no spaces"));
            username_entry.changed.connect (check_input);

            error_label = new Gtk.Label ("");
            error_label.set_halign (Gtk.Align.END);
            error_label.get_style_context ().add_class ("error");
            error_label.use_markup = true;

            error_revealer = new Gtk.Revealer ();
            error_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
            error_revealer.add (error_label);

            pw_editor = new Widgets.PasswordEditor ();
            pw_editor.validation_changed.connect (check_input);

            pw_revealer = new Gtk.Revealer ();
            pw_revealer.add (pw_editor);
            pw_revealer.set_reveal_child (true);

            button_create = new Gtk.Button.with_label (_("Create User"));
            button_create.halign = Gtk.Align.END;
            button_create.margin_top = 12;
            button_create.set_sensitive (false);
            button_create.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
            button_create.set_size_request (100, 25);
            button_create.clicked.connect (() => {
                string fullname = fullname_entry.get_text ();
                string username = username_entry.get_text ();
                Act.UserPasswordMode mode = Act.UserPasswordMode.NONE;
                string? pw = null;
                Act.UserAccountType accounttype = Act.UserAccountType.STANDARD;
                if (accounttype_combobox.get_active () == 1)
                    accounttype = Act.UserAccountType.ADMINISTRATOR;

                request_user_creation (fullname, username, accounttype, mode, pw);
                hide ();
                destroy ();
            });

            grid = new Gtk.Grid ();
            grid.margin = 12;
            grid.row_spacing = 12;
            grid.attach (accounttype_combobox, 0, 0, 1, 1);
            grid.attach (fullname_entry, 0, 1, 2, 1);
            grid.attach (username_entry, 0, 2, 2, 1);
            grid.attach (error_revealer, 0, 3, 2, 1);
            grid.attach (pw_revealer, 0, 6, 1, 1);
            grid.attach (button_create, 0, 7, 1, 1);

            add (grid);
        }

        private void check_input () {

            bool username_is_valid = is_valid_username (username_entry.get_text ());
            bool username_is_taken = is_taken_username (username_entry.get_text ());
            if (fullname_entry.get_text() != "" && username_entry.get_text () != ""
            && pw_editor.is_valid && username_is_valid && !username_is_taken) {
                    button_create.set_sensitive (true);
                    error_revealer.set_reveal_child (false);
            } else {
                button_create.set_sensitive (false);
                if (username_is_taken || (!username_is_valid && username_entry.get_text () != "")) {
                    if (username_is_taken)
                        error_label.set_label ("<span font_size=\"small\">%s</span>".printf
                            (_("Username is already taken")));
                    else if (!username_is_valid)
                        error_label.set_label ("<span font_size=\"small\">%s</span>".printf
                            (_("Username is not valid")));

                    error_revealer.set_reveal_child (true);
                } else
                    error_revealer.set_reveal_child (false);
            }
        }
    }
}
