---
layout: default
title: dataware client 
showinnav: true
---

# This is some content?
## and so is this
{% for page in site.htmdataware_client %}
    {% if page.title %}
        {% if page.showinnav == true %}
            <li> <a href="{{page.url | remove:'index.html'}}">{{page.title}}</a></li>
        {% endif %}
    {% endif %}
{% endfor %}