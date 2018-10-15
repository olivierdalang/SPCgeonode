# -*- coding: utf-8 -*-

from django import template
from django.conf import settings
from django.utils.safestring import mark_safe

register = template.Library()

snippet = '''
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id={ga_id}"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){{dataLayer.push(arguments);}}
  gtag('js', new Date());
  gtag('config', '{ga_id}');
</script>'''

@register.simple_tag(takes_context=False)
def google_analytics():
    if settings.GOOGLE_ANALYTICS_ID:
        return mark_safe(snippet.format(ga_id=settings.GOOGLE_ANALYTICS_ID))
    else:
        return mark_safe('<!-- GOOGLE_ANALYTICS_ID not set -->')
