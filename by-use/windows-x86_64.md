---
title: Linux-x86_64
---

<table>
<tr>
<th>Machine</th>
<th>Model</th>
<th>OS</th>
<th>Threads</th>
<th>Location</th>
</tr>
{% assign lower_title = page.title | downcase %}
{% for item in site.machines %}
{% assign lower_pool = item.pool | downcase %}
{% if lower_pool == lower_title %}
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

