import pathlib
import re
from collections import defaultdict

here = pathlib.Path(__file__).parent
themes_dir = here / 'themes'
target_dir = here.parent/'lua'/ 'nvim-web-devicons'/ 'themes'

themes_map = defaultdict(dict)

# gen theme data
for define in themes_dir.iterdir():
    theme_name = define.name
    with open(define, encoding='utf8') as f:
        for line in f:
            line = re.sub(r'\s+', ' ', line).strip(' ')
            if not line and line.startswith('#'):
                continue
            line = line.split(' ')
            keys = line[0].split('|')
            icon = line[1]
            color = line[2]
            for key in keys:
                try:
                    name = line[3]
                except IndexError:
                    name = re.sub(r'[\._\-]', '', key.title())
                themes_map[theme_name][key] = dict(icon=icon, color=color, name=name)

# combine
default_theme_data = themes_map.pop('default')  # type: dict
for theme_name, theme_data in themes_map.items():
    temp = default_theme_data.copy()
    temp.update(theme_data)
    themes_map[theme_name] = temp
themes_map['default'] = default_theme_data

# write lua code
for theme_name, theme_data in themes_map.items():
    theme_items = []
    for key, item_data in theme_data.items():
        icon, color, name = item_data['icon'], item_data['color'], item_data['name']
        theme_items.append(
            '["%s"] = { icon = "%s", color="%s", name = "%s"},'
            % (key, icon, color, name)
        )
    with open(target_dir / f'{theme_name}.lua', 'w', encoding='utf8') as f:
        f.write(
            'local icons = {\n  %s\n}\nreturn icons' % '\n  '.join(theme_items),
        )
