class MoveRotation implements SceneObject
{
  SceneObject child;
  PVector movement;
  PVector rotation;

  MoveRotation(SceneObject child, PVector movement, PVector rotation)
  {
    this.child = child;
    this.movement = movement;
    this.rotation = rotation;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    PVector newOrigin = r.origin.copy();
    PVector newDirection = r.direction.copy();
    ArrayList<RayHit> hits = new ArrayList<RayHit>();

    translateInverse(newOrigin, movement);
    rotateInverseY(newOrigin, rotation);
    rotateInverseX(newOrigin, rotation);
    rotateInverseZ(newOrigin, rotation);
    rotateInverseY(newDirection, rotation);
    rotateInverseX(newDirection, rotation);
    rotateInverseZ(newDirection, rotation);

    Ray rNew = new Ray(newOrigin, newDirection);
    hits.addAll(child.intersect(rNew));

    for (int i = 0; i < hits.size(); i++)
    {
      hits.get(i).normal = hits.get(i).normal.copy();
      rotateZ(hits.get(i).location, rotation);
      rotateX(hits.get(i).location, rotation);
      rotateY(hits.get(i).location, rotation);
      translate(hits.get(i).location, movement);
      rotateZ(hits.get(i).normal, rotation);
      rotateX(hits.get(i).normal, rotation);
      rotateY(hits.get(i).normal, rotation);
    }

    return hits;
  }
}

class Scaling implements SceneObject
{
  SceneObject child;
  PVector scaling;

  Scaling(SceneObject child, PVector scaling)
  {
    this.child = child;
    this.scaling = scaling;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    PVector newOrigin = r.origin.copy();
    PVector newDirection = r.direction.copy();
    ArrayList<RayHit> hits = new ArrayList<RayHit>();

    scaleInverse(newOrigin, scaling);
    scaleInverse(newDirection, scaling);

    Ray rNew = new Ray(newOrigin, newDirection.normalize());
    hits.addAll(child.intersect(rNew));

    for (int i = 0; i < hits.size(); i++)
    {
      scale(hits.get(i).location, scaling);
      scale(hits.get(i).normal, scaling);
    }

    return hits;
  }
}

void translate(PVector v, PVector m)
{
  PVector.add(v, m, v);
}

void rotateZ(PVector v, PVector r)
{
  float x = cos(r.z)*v.x - sin(r.z)*v.y;
  float y = sin(r.z)*v.x + cos(r.z)*v.y;
  v.x = x;
  v.y = y;
}

void rotateY(PVector v, PVector r)
{
  float x = cos(r.y)*v.x + sin(r.y)*v.z;
  float z = -sin(r.y)*v.x + cos(r.y)*v.z;
  v.x = x;
  v.z = z;
}

void rotateX(PVector v, PVector r)
{
  float y = cos(r.x)*v.y - sin(r.x)*v.z;
  float z = sin(r.x)*v.y + cos(r.x)*v.z;
  v.y = y;
  v.z = z;
}

void translateInverse(PVector v, PVector m)
{
  PVector.sub(v, m, v);
}

void rotateInverseZ(PVector v, PVector r)
{
  float x = cos(-r.z)*v.x - sin(-r.z)*v.y;
  float y = sin(-r.z)*v.x + cos(-r.z)*v.y;
  v.x = x;
  v.y = y;
}

void rotateInverseY(PVector v, PVector r)
{
  float x = cos(-r.y)*v.x + sin(-r.y)*v.z;
  float z = -sin(-r.y)*v.x + cos(-r.y)*v.z;
  v.x = x;
  v.z = z;
}

void rotateInverseX(PVector v, PVector r)
{
  float y = cos(-r.x)*v.y - sin(-r.x)*v.z;
  float z = sin(-r.x)*v.y + cos(-r.x)*v.z;
  v.y = y;
  v.z = z;
}

void scale(PVector v, PVector s)
{
  v.x = v.x * s.x;
  v.y = v.y * s.y;
  v.z = v.z * s.z;
}

void scaleInverse(PVector v, PVector s)
{
  v.x = v.x / s.x;
  v.y = v.y / s.y;
  v.z = v.z / s.z;
}
