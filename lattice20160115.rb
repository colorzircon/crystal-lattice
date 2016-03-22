Model = Sketchup.active_model
Entities = Model.entities
Selection = Model.selection
Origin = [0, 0, 0]
TetrAngle = Math.atan(Math.sqrt(2))
Zed = Geom::Transformation.rotation Origin, [0, 0, 1], Math::PI/4
Ex = Geom::Transformation.rotation Origin, [1, 0, 0], TetrAngle
UnZed = Geom::Transformation.rotation Origin, [0, 0, 1], -Math::PI/4
UnEx = Geom::Transformation.rotation Origin, [1, 0, 0], -TetrAngle


def toHex
  Selection[0].transform! Zed
  Selection[0].transform! Ex
  group = Entities.add_group Selection[0]
  group.entities[0].explode
  return group
end


def toCubic
  Selection[0].transform! UnEx
  Selection[0].transform! UnZed
  group = Entities.add_group Selection[0]
  group.entities[0].explode
  return group
end


def hexMinor (length)
  yCoord = -Math.sqrt(3)/3
  zCoord = Math.sin(Math.acos(Math.sqrt(3)/3))


  Entities.add_face Origin, [0, yCoord * length, zCoord * length], [0, yCoord * length, 0]
end


def cubeMinor (length)
  xCoord = Math.sin(Math.acos(2.0/3.0))
  zCoord = 2.0/3.0


  Entities.add_face Origin, [xCoord * length, 0, zCoord * length], [0, 0, zCoord * length]
end


def cubeFace (length)
  octahedronPoint = [0,-length,0]
  tetrahedronPoint = [0, -Math.cos(Math::PI/8) * length, Math.sin(Math::PI/8) * length]
  fccPoint = [0, -Math.sqrt(2) * (length/2), Math.sqrt(2) * (length/2)]
  bccPoint = [length/Math.sqrt(3), -length/Math.sqrt(3), length/Math.sqrt(3)]


  group = Entities.add_group
  group.entities.add_face octahedronPoint, bccPoint, tetrahedronPoint
  group.entities.add_face tetrahedronPoint, bccPoint, fccPoint


  return group
end


def copyPaste (group, n, j, r)
  i = 0
  while i < n
    group.entities[i].copy
    group.entities[i + j].transform! r
    i += 1
  end
end


def popOut (group, n)
  i = 0
  while i < n
    group.entities[0].explode
    i += 1
  end
end


def hexSphere
  rotation = Geom::Transformation.rotation Origin, [0,0,1], Math::PI/3
  i = 0
  hexArray = [Selection[0]]
  while i < 5
    hexArray.push(hexArray[i].copy)
    hexArray[i + 1].transform! rotation
    Selection.add hexArray[i + 1]
    i += 1
  end
  group = Entities.add_group Selection
  popOut group, 6
  return group
end


def cubeSphere (length)
  flip = Geom::Transformation.scaling Origin, -1, 1, 1
  rotationX1 = Geom::Transformation.rotation [0, length, 0], [1, 0, 0], Math::PI/2
  rotationX2 = Geom::Transformation.rotation [0, length, 0], [-1, 0, 0], Math::PI/2
  rotationY = Geom::Transformation.rotation Origin, [0, 1, 0], Math::PI/2
  rotationZ = Geom::Transformation.rotation [0, length, 0], [0, 0, 1], Math::PI/2
  
  sphereGroup = Entities.add_group Selection
  sphereGroup.entities[0].copy
  sphereGroup.entities[1].transform! flip


  copyPaste sphereGroup, 6, 2, rotationY
  copyPaste sphereGroup, 24, 8, rotationZ
  copyPaste sphereGroup, 8, 32, rotationX1
  copyPaste sphereGroup, 8, 40, rotationX2
  popOut sphereGroup, 48
end


def comboSphere
  rotation = Geom::Transformation.rotation Origin, [0,0,1], Math::PI/2
  i = 0
  comboArray = [Selection[0]]
  while i < 3
    comboArray.push(comboArray[i].copy)
    comboArray[i + 1].transform! rotation
    Selection.add comboArray[i + 1]
    i += 1
  end
  group = Entities.add_group Selection
  return group
end


def intersectArcs (plane1, plane2, length)
  line = Geom.intersect_plane_plane(plane1, plane2)
  if line.is_a? Array
    projection = Origin.project_to_line line
    cosineVector = Origin.vector_to projection
    if ((Origin.distance projection) / length) <= 1
      angle = Math.acos((Origin.distance projection) / length)
      sineVector = line[1]
      sineVector.length = Math.sin(angle) * length
      intersection = [cosineVector + sineVector, cosineVector - sineVector]
      Entities.add_line intersection[0].to_a, intersection[1].to_a
    end
  end
end


def theseTwo (length)
  intersectArcs Selection[0].plane, Selection[1].plane, length
end


def rings (length)
  toDo = []
  Selection.each {|element|
    if element.is_a? Sketchup::Face
      toDo.push element
    end
  }
  i = 1
  while i < toDo.length
    j = 1
    while j < toDo.length
      intersectArcs toDo[0].plane, toDo[j].plane, length
      j += 1
    end
    toDo.delete_at 0  
    i += 1
  end
end