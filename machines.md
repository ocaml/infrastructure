---
title: Machines
toc: false
classes: wide
---

{% include machines-map.html %}

<table>
<tr>
<th>Machine</th>
<th>Model</th>
<th>OS</th>
<th>Threads</th>
<th>Location</th>
<th>Notes</th>
</tr>
{% for item in site.machines %}
{% if item.pool == nil %}
<tr>
<td><a href="/{{item.path | replace: "_machines", "machines" | replace: ".md", ".html"}}">{{item.name}}</a></td>
<td>{{item.manufacturer}} {{item.model}}</td>
<td>{{item.os}}</td>
<td>{{item.threads}}</td>
<td>{{item.location}}</td>
<td>{{item.notes}}</td>
</tr>
{% endif %}
{% endfor %}
</table>

{% assign pools = "linux-x86_64,linux-ppc64,linux-arm64,windows-x86_64,linux-s390x,linux-riscv64,macos-x86_64,macos-arm64,windows-amd64,openbsd-amd64" | split: ',' %}
{% for pool in pools %}

# Worker Pool {{pool}}

<table>
<tr>
<th>Machine</th>
<th>Model</th>
<th>OS</th>
<th>Threads</th>
<th>Location</th>
</tr>
{% for item in site.machines %}
{% if item.pool == pool %}
<tr>
<td><a href="/{{item.path | replace: "_machines", "machines" | replace: ".md", ".html"}}">{{item.name}}</a></td>
<td>{{item.manufacturer}} {{item.model}}</td>
<td>{{item.os}}</td>
<td>{{item.threads}}</td>
<td>{{item.location}}</td>
</tr>
{% endif %}
{% endfor %}
</table>

{% endfor %}

