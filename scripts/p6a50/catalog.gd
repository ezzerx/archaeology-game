extends RefCounted
const IDS:=["M08","B17"]
static func entry(id:String) -> Dictionary:
 if id=="M08":
  return {"id":"M08","code":"M–08","name":"Ammonite côtelée","provenance":"Bassin des Aulnes · dépôt marin","note":"Une pièce compacte, prise dans une argile fine. Suivez les reliefs qui apparaissent.","rhythm":"Préparation courte · courbes & détails","model":"res://assets/p6a50/m08_ammonite.glb","field":"res://assets/p6a50/mesh_patch_data.res","legacy":"Specimen M-08","classifications":["Indéterminé","Coquille fossilisée","Coquille en spirale","Ammonite côtelée"],"components":["—","Tour extérieur","Tours internes","Ombilic","Ouverture"]}
 return {"id":"B17","code":"B–17","name":"Petit théropode","provenance":"Ravin des Ocres · dépôt continental","note":"Un grand bloc, plusieurs éléments articulés. Prenez le temps de suivre leurs contours.","rhythm":"Préparation ample · pièces articulées","model":"res://assets/p6a37/b17_skeleton.glb","field":"res://assets/p6a37/mesh_patch_data.res","legacy":"Specimen B-17","classifications":["Indéterminé","Restes de vertébré","Théropode probable","Petit théropode"],"components":["—","Crâne","Vertèbres","Côtes","Patte arrière"]}
