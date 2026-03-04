Name:           leetium
Version:        0.1.0
Release:        1%{?dist}
Summary:        Personal AI gateway inspired by OpenClaw
License:        MIT
URL:            https://www.leetnex.ru/

%description
Leetium is a personal AI gateway inspired by OpenClaw. One binary, multiple LLM providers.

%install
mkdir -p %{buildroot}%{_bindir}
install -m 755 %{_sourcedir}/leetium %{buildroot}%{_bindir}/leetium

%files
%{_bindir}/leetium
