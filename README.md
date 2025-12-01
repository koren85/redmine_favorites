# Redmine Favorites Plugin

A Redmine plugin that allows users to mark issues as favorites and quickly access them.

[Русская версия](README_ru.md)

## Features

* Add issues to favorites
* Remove issues from favorites
* View list of favorite issues
* Favorite icons on issue page, issue list, and edit page
* Context menu item for adding/removing issues from favorites
* Global menu item for quick access to favorite issues
* Support for standard Redmine filters for favorite issues list
* Favorite filter in standard Redmine queries ("My Favorites")
* Favorite icon column in issues list (positioned before issue number)
* My page widget to display favorite issues

## Installation

1. Clone the repository into your Redmine plugins directory:

```bash
cd /path/to/redmine/plugins
git clone https://github.com/koren85/redmine_favorites
```

2. Install dependencies (if any):

```bash
cd /path/to/redmine
bundle install
```

3. Run database migrations:

```bash
cd /path/to/redmine
rake redmine:plugins:migrate RAILS_ENV=production
```

4. Restart Redmine:

```bash
touch tmp/restart.txt
```

## Usage

### Basic Operations

* To add an issue to favorites, click the star icon on the issue page or in the issue list
* To view favorite issues, click the "Favorites" item in the top menu
* To remove an issue from favorites, click the star icon again
* For bulk adding/removing issues from favorites, select the desired issues and use the context menu item

### Advanced Features

#### Favorite Filter in Queries

You can filter issues by favorite status in any Redmine query:
1. Go to any issues list
2. Click "Add filter"
3. Select "Favorite issues"
4. Choose "Yes" to show only favorites or "No" to exclude favorites

#### My Page Widget

Add favorite issues widget to your personal page:
1. Go to "My page" (top right menu → "My page")
2. Click "Personalize this page"
3. Find "Favorite issues" in the available blocks
4. Drag it to the desired position
5. Click "Save"

The widget displays your 10 most recent favorite issues.

## Features

* AJAX processing for adding/removing issues from favorites without page reload
* Smooth animations when adding/removing issues from favorites
* Automatic notification hiding
* Custom icon support for better display quality
* Visual indication of add/remove process
* Personal favorites list for each user (privacy protected)
* Compatible with additional_tags plugin and other popular Redmine plugins
* Global plugin - no need to enable per project

## Compatibility

### Tested with Redmine versions:
* 4.1.x
* 4.2.x
* 5.0.x (should work, not fully tested)

### Compatible plugins:
* additional_tags - full compatibility
* additionals - full compatibility
* redmine_issue_templates - full compatibility

## Languages

* English
* Russian

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/koren85/redmine_favorites.

## License

MIT License

Copyright (c) 2025 Chernyaev Alexandr

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Author

Chernyaev Alexandr

## Changelog

### Version 0.0.1 (Initial Release)

* Basic favorite functionality
* Favorite icons in issue page and list
* Global favorites menu
* Context menu integration
* AJAX support
* Favorite filter in queries
* My page widget
* Multi-language support (EN, RU)
