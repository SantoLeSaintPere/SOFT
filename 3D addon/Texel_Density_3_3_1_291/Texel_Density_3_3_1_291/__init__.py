bl_info = {
	"name": "Texel Density Checker",
	"description": "Tools for for checking Texel Density and wasting of uv space",
	"author": "Ivan 'mrven' Vostrikov, Toomas Laik",
	"wiki_url": "https://gumroad.com/l/CEIOR",
	"tracker_url": "https://blenderartists.org/t/texel-density-checker-3-0-update-09-04-20/685566",
	"version": (3, 3, 1),
	"blender": (2, 91, 0),
	"location": "3D View > Toolbox",
	"category": "Object",
}

modules_names = ['props', 'preferences', 'utils', 'core_td_operators', 'add_td_operators', 'viz_operators', 'ui']

modules_full_names = {}
for current_module_name in modules_names:
	modules_full_names[current_module_name] = ('{}.{}'.format(__name__, current_module_name))

import sys
import importlib


for current_module_full_name in modules_full_names.values():
	if current_module_full_name in sys.modules:
		importlib.reload(sys.modules[current_module_full_name])
	else:
		globals()[current_module_full_name] = importlib.import_module(current_module_full_name)
		setattr(globals()[current_module_full_name], 'modulesNames', modules_full_names)

def register():
	for current_module_name in modules_full_names.values():
		if current_module_name in sys.modules:
			if hasattr(sys.modules[current_module_name], 'register'):
				sys.modules[current_module_name].register()

def unregister():
	for current_module_name in modules_full_names.values():
		if current_module_name in sys.modules:
			if hasattr(sys.modules[current_module_name], 'unregister'):
				sys.modules[current_module_name].unregister()