---
title: General
---

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
{% if item.pool == nil and item.use == nil %}
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

