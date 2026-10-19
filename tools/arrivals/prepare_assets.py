"""Blender 4.3+; preserve originals, fit metre-scale copies and export runtime GLBs."""
import bpy,json,hashlib
from pathlib import Path
root=Path(__file__).resolve().parents[2]
settings={'crate_body':((.90,.62,.27),.45),'crate_lid':((.916,.636,.045),.45),'reception_counter':((2.8,1.24,.85),.50)}
report={}
for name,(dims,ratio) in settings.items():
 bpy.ops.wm.read_factory_settings(use_empty=True)
 bpy.context.preferences.filepaths.save_version=0
 source=root/'assets/arrivals/source/tripo-studio'/name/'original.glb'
 bpy.ops.import_scene.gltf(filepath=str(source))
 objects=[o for o in bpy.context.scene.objects if o.type=='MESH']
 bpy.ops.object.select_all(action='DESELECT')
 for o in objects:o.select_set(True)
 bpy.context.view_layer.objects.active=objects[0]
 if len(objects)>1:bpy.ops.object.join()
 ob=bpy.context.object;ob.name=name
 # Blender Z is glTF Y. The supplied models are already centred and floor-aligned.
 ob.dimensions=dims;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 lo=[min(v.co[i] for v in ob.data.vertices) for i in range(3)];hi=[max(v.co[i] for v in ob.data.vertices) for i in range(3)]
 for v in ob.data.vertices:v.co.x-=(lo[0]+hi[0])/2;v.co.y-=(lo[1]+hi[1])/2;v.co.z-=lo[2]
 bpy.ops.wm.save_as_mainfile(filepath=str(source.parent/'fitted.blend'))
 before=sum(len(p.vertices)-2 for p in ob.data.polygons)
 mod=ob.modifiers.new('Runtime reduction','DECIMATE');mod.ratio=ratio
 bpy.ops.object.modifier_apply(modifier=mod.name)
 for p in ob.data.polygons:p.use_smooth=True
 # Keep originals packed in fitted.blend; runtime samples are reduced separately.
 textures=[]
 for img in bpy.data.images:
  if img.type!='IMAGE':continue
  if not img.size[0]:continue
  _=img.pixels[0]
  original=list(img.size)
  if max(img.size)>2048:
   fac=2048/max(img.size);img.scale(round(img.size[0]*fac),round(img.size[1]*fac))
  img.pack();textures.append({'name':img.name,'source_size':original,'runtime_size':list(img.size)})
 for mat in bpy.data.materials:
  if not mat.use_nodes:continue
  for n in mat.node_tree.nodes:
   if n.type=='NORMAL_MAP':n.inputs['Strength'].default_value=.55
 bpy.ops.export_scene.gltf(filepath=str(root/'assets/arrivals/models'/f'{name}.glb'),export_format='GLB',use_selection=True,export_image_format='JPEG',export_jpeg_quality=93,export_yup=True)
 report[name]={'source_triangles':before,'runtime_triangles':sum(len(p.vertices)-2 for p in ob.data.polygons),'dimensions_blender_xyz':list(ob.dimensions),'textures':textures,'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest()}
(root/'assets/arrivals/models/budgets.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
