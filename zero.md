---
title: "Machine with no thread count"
---

<table>
<tr>
<th>Machine</th>
<th>Model</th>
<th>OS</th>
<th>Threads</th>
<th>Location</th>
<th>Pool</th>
<th>Notes</th>
</tr>
{% for item in site.machines %}
{% if item.threads == nil %}
<tr>
<td><a href="/machines/{{item.name}}.html">{{item.name}}</a></td>
<td>{{item.manufacturer}} {{item.model}}</td>
<td>{{item.os}}</td>
<td>{{item.threads}}</td>
<td>{{item.location}}</td>
<td>{{item.pool}}</td>
<td>{{item.notes}}</td>
</tr>
{% endif %}
{% endfor %}
</table>

