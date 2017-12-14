# Customization sample

This is an example app to customize Geonode.

## Overrides

The logo is overridden by `static/geonode/img/logo.png` and the base template is overridden by `templates/base.html` (to add a new menu item).

## New pages

A new page is added (`custom_page`) by providing a template and a TemplateView is added in `urls.py`.
