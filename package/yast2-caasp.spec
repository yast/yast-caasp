#
# spec file for package yast2-registration
#
# Copyright (c) 2017 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-caasp
Version:        1.0.2
Release:        0

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2

Group:          System/YaST
License:        GPL-2.0

# SystemRoleHandlersRunner
Requires:       yast2-installation >= 3.1.217.30
Requires:       yast2
Requires:       yast2-ntp-client   >= 3.1.28.1

# SystemRoleHandlersRunner
BuildRequires:  yast2-installation >= 3.1.217.30
BuildRequires:  yast2
BuildRequires:  yast2-ntp-client   >= 3.1.28.1
BuildRequires:  yast2-devtools >= 3.1.39
BuildRequires:  rubygem(yast-rake) >= 0.2.13
BuildRequires:  rubygem(rspec)

BuildArch:      noarch

Summary:        YaST2 - CaaSP Module
Url:            https://github.com/yast/yast-caasp

%description
Containers as a Service Platform (CaaSP) specific module.


Authors:
--------
    YaST Team <yast-devel@opensuse.org>

%prep
%setup -n %{name}-%{version}

%build

%check
%yast_check

%install
%yast_install

%files
%defattr(-,root,root)
%dir %{yast_libdir}/y2caasp
%dir %{yast_libdir}/y2caasp/cfa
%{yast_libdir}/y2caasp/cfa/*.rb
%dir %{yast_libdir}/y2system_role_handlers
%{yast_libdir}/y2system_role_handlers/*.rb
%doc %{yast_docdir}

%changelog
