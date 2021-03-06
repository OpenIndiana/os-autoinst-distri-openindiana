# OpenIndiana's openQA tests
#
# Copyright © 2017-2018 Michal Nowak
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Test VirtualBox Guest Additions' installation & functionality
# Maintainer: Michal Nowak <mnowak@startmail.com>

use base 'consoletest';
use strict;
use testapi;
use utils qw(pkg_call get_vbox_guest_additions wait_boot power_action);

sub test_vbox_props {
    assert_script_run 'modinfo | grep -w vboxguest';
    assert_script_run 'modinfo | grep -w vboxms';
    assert_script_run 'svcs vboxservice | grep ^online';
    assert_script_run 'svcs vboxmslnk | grep ^online';
}

sub run {
    select_console 'user-console';

    get_vbox_guest_additions if check_var('VIRSH_VMM_FAMILY', 'virtualbox');
    # Configure guest management tools. $PACKER_BUILDER_TYPE is required by
    # the Vagrant 'vmtools' shell script.
    assert_script_run "export PACKER_BUILDER_TYPE=virtualbox";
    assert_script_run 'wget ' . data_url("vagrant/vmtools.sh");
    my $script = 'vmtools';
    assert_script_run "chmod +x $script.sh";
    assert_script_sudo "-E ./$script.sh";
    assert_script_run "rm $script.sh";

    # Test VBox Guest Additions' presence
    test_vbox_props;
    power_action('reboot');
    wait_boot;
    select_console 'user-console';
    test_vbox_props;
}

sub test_flags {
    return {fatal => 1};
}

1;

# vim: set sw=4 et:
