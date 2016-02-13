---
layout: page
title: Training
permalink: /training/
---
# Available Training Modules

<ul>
{% for page in site.training %}
  <li>
    <a class="page-link" href="{{ page.url | prepend: site.baseurl }}">{{page.title}}</a>
  </li>
{% endfor %}
</ul>
