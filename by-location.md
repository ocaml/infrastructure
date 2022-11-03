---
layout: page
title: Machines by Location
permalink: /location/
---

{% assign locations = "Caelum,Equinix,Scaleway,AWS,Marist College,Custodian" | split: ',' %}
{% for location in locations %}

# {{location}}

<table>
<tr>
<th>Machine</th>
<th>Model</th>
<th>Threads</th>
<th>Notes</th>
</tr>
{% for item in site.machines %}
{% if item.location contains location %}
<tr>
<td><a href="/machines/{{item.name}}.html">{{item.name}}</a></td>
<td>{{item.manufacturer}} {{item.model}}</td>
<td>{{item.threads}}</td>
<td>{{item.notes}}</td>
</tr>
{% endif %}
{% endfor %}
</table>

{% endfor %}

