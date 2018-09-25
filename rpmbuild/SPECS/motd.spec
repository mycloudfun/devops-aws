Name:           motd
Version:        1.1
Release:        1
Summary:        My Custom MOTD

License:        GPL
Source0:        motd-%{version}.tar.gz
BuildArch:	noarch
%define _topdir %(echo $PWD)/

%description
This is my custom MOTD config

%prep
%setup -q

%install
rm -rf $RPM_BUILD_ROOT
install -d $RPM_BUILD_ROOT/etc
install motd $RPM_BUILD_ROOT/etc/motd

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
/etc/motd
%doc

%post
chmod 644 /etc/motd

%changelog
