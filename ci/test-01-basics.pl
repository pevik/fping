#!/usr/bin/perl -w

use Test::Command tests => 18;
use Test::More;

# ping 127.0.0.1
{
    my $cmd = Test::Command->new(cmd => "fping 127.0.0.1");
    $cmd->exit_is_num(0);
    $cmd->stdout_is_eq("127.0.0.1 is alive\n");
    $cmd->stderr_is_eq("");
}

# ping ::1
SKIP: {
    #system("/sbin/ifconfig >&2");
    if($ENV{SKIP_IPV6}) {
        skip 'Skip IPv6 tests', 3;
    }
    my $cmd = Test::Command->new(cmd => "fping ::1");
    $cmd->exit_is_num(0);
    $cmd->stdout_is_eq("::1 is alive\n");
    $cmd->stderr_is_eq("");
}

# ping ff02::1
SKIP: {
    #system("/sbin/ifconfig >&2");
    if($ENV{SKIP_IPV6}) {
        skip 'Skip IPv6 tests', 3;
    }
    my $cmd = Test::Command->new(cmd => "fping ff02::1");
    $cmd->exit_is_num(0);
    $cmd->stdout_is_eq("ff02::1 is alive\n");
    $cmd->stderr_like(qr{ \[<- .*\]});
}

# ping ::ffff:127.0.0.1
SKIP: {
    if($ENV{SKIP_IPV6}) {
        skip 'Skip IPv6 tests', 3;
    }
    my $cmd = Test::Command->new(cmd => "fping ::ffff:127.0.0.1");
    $cmd->exit_is_num(0);
    $cmd->stdout_is_eq("IPv4-Mapped-in-IPv6 address, using IPv4 127.0.0.1
127.0.0.1 is alive\n");
    $cmd->stderr_like(qr{ \[<- 127.0.0.1\]});
}

# ping 3 times 127.0.0.1
{
    my $cmd = Test::Command->new(cmd => "fping -p 100 -C3 127.0.0.1");
    $cmd->exit_is_num(0);
    $cmd->stdout_like(qr{127\.0\.0\.1 : \[0\], 64 bytes, \d\.\d+ ms \(\d\.\d+ avg, 0% loss\)
127\.0\.0\.1 : \[1\], 64 bytes, \d\.\d+ ms \(\d\.\d+ avg, 0% loss\)
127\.0\.0\.1 : \[2\], 64 bytes, \d\.\d+ ms \(\d\.\d+ avg, 0% loss\)
});
    $cmd->stderr_like(qr{127\.0\.0\.1 : \d\.\d+ \d\.\d+ \d\.\d+\n});
}

# invalid target name
{
    my $cmd = Test::Command->new(cmd => "fping host.name.invalid");
    $cmd->exit_is_num(2);
    $cmd->stdout_is_eq("");
    $cmd->stderr_like(qr{host\.name\.invalid: .+\n});
}
