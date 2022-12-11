class Sphere implements SceneObject //<>// //<>// //<>// //<>//
{
  PVector center;
  float radius;
  Material material;

  Sphere(PVector center, float radius, Material material)
  {
    this.center = center;
    this.radius = radius;
    this.material = material;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    ArrayList<RayHit> result = new ArrayList<RayHit>();

    RayHit rayHit1 = new RayHit();
    RayHit rayHit2 = new RayHit();

    float tP = PVector.dot(PVector.sub(center, r.origin), r.direction);
    PVector p = PVector.add(r.origin, PVector.mult(r.direction, tP));

    rayHit1.t = tP + sqrt(sq(radius) - sq(PVector.dist(p, center)));
    rayHit2.t = tP - sqrt(sq(radius) - sq(PVector.dist(p, center)));
    rayHit1.location = PVector.add(r.origin, PVector.mult(r.direction, rayHit1.t));
    rayHit2.location = PVector.add(r.origin, PVector.mult(r.direction, rayHit2.t));
    rayHit1.normal = PVector.sub(rayHit1.location, center).normalize();
    rayHit2.normal = PVector.sub(rayHit2.location, center).normalize();
    rayHit1.material = material;
    rayHit2.material = material;
    rayHit1.entry = false;
    rayHit2.entry = true;
    rayHit1.u = 0.5 + atan2(rayHit1.normal.y, rayHit1.normal.x) / TWO_PI;
    rayHit1.v = 0.5 - asin(rayHit1.normal.z) / PI;
    rayHit2.u = 0.5 + atan2(rayHit2.normal.y, rayHit2.normal.x) / TWO_PI;
    rayHit2.v = 0.5 - asin(rayHit2.normal.z) / PI;

    if (rayHit2.t > 0)
    {
      result.add(rayHit2);
    }

    if (rayHit1.t > 0)
    {
      result.add(rayHit1);
    }

    return result;
  }
}

class Plane implements SceneObject
{
  PVector center;
  PVector normal;
  float scale;
  Material material;
  PVector left;
  PVector up;

  Plane(PVector center, PVector normal, Material material, float scale)
  {
    this.center = center;
    this.normal = normal.normalize();
    this.material = material;
    this.scale = scale;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    ArrayList<RayHit> result = new ArrayList<RayHit>();
    RayHit rayHit = new RayHit();
    PVector z = new PVector(0, 0, 1);
    PVector y = new PVector(0, 1, 0);

    if (PVector.dot(r.direction, normal) != 0)
    {
      rayHit.t = PVector.dot(PVector.sub(center, r.origin), normal) / PVector.dot(r.direction, normal);

      if (rayHit.t > 0)
      {
        rayHit.material = material;
        rayHit.location = PVector.add(r.origin, PVector.mult(r.direction, rayHit.t));
        rayHit.normal = normal;
        PVector right = new PVector(0, 0, 0);
        if (PVector.dot(rayHit.normal, z) != 0)
        {
          right = y.cross(rayHit.normal).normalize();
        } else
        {
          right = z.cross(rayHit.normal).normalize();
        }
        PVector up = rayHit.normal.cross(right).normalize();
        PVector d = PVector.sub(rayHit.location, center);
        float xCoordinate = PVector.dot(d, right) / scale;
        float yCoordinate = PVector.dot(d, up) / scale;
        rayHit.u = xCoordinate - floor(xCoordinate);
        rayHit.v = (-yCoordinate) - floor(-yCoordinate);

        if (PVector.dot(r.direction, normal) < 0)
        {
          rayHit.entry = true;
          result.add(rayHit);
        } else
        {
          rayHit.entry = false;
          result.add(rayHit);
        }
      }
    }

    if (PVector.dot(PVector.sub(r.origin, center), normal) < 0 && PVector.dot(r.direction, normal) <= 0)
    {
      rayHit.t = Float.POSITIVE_INFINITY;
      rayHit.material = material;
      rayHit.location = PVector.add(r.origin, PVector.mult(r.direction, rayHit.t));
      rayHit.normal = normal;
      rayHit.entry = false;
      PVector right = new PVector(0, 0, 0);
      if (PVector.dot(rayHit.normal, z) != 0)
      {
        right = y.cross(rayHit.normal).normalize();
      } else
      {
        right = z.cross(rayHit.normal).normalize();
      }
      PVector up = rayHit.normal.cross(right).normalize();
      PVector d = PVector.sub(rayHit.location, center);
      float xCoordinate = PVector.dot(d, right) / scale;
      float yCoordinate = PVector.dot(d, up) / scale;
      rayHit.u = xCoordinate - floor(xCoordinate);
      rayHit.v = (-yCoordinate) - floor(-yCoordinate);
      result.add(rayHit);
    }
    return result;
  }
}

class Triangle implements SceneObject
{
  PVector v1;
  PVector v2;
  PVector v3;
  PVector normal;
  PVector tex1;
  PVector tex2;
  PVector tex3;
  Material material;

  Triangle(PVector v1, PVector v2, PVector v3, PVector tex1, PVector tex2, PVector tex3, Material material)
  {
    this.v1 = v1;
    this.v2 = v2;
    this.v3 = v3;
    this.tex1 = tex1;
    this.tex2 = tex2;
    this.tex3 = tex3;
    this.normal = PVector.sub(v2, v1).cross(PVector.sub(v3, v1)).normalize();
    this.material = material;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    ArrayList<RayHit> result = new ArrayList<RayHit>();
    RayHit rayHit = new RayHit();

    if (PVector.dot(r.direction, normal) != 0)
    {
      rayHit.t = PVector.dot(PVector.sub(v1, r.origin), normal) / PVector.dot(r.direction, normal);

      if (rayHit.t >= 0)
      {
        rayHit.location = PVector.add(r.origin, PVector.mult(r.direction, rayHit.t));
        if (PointInTriangle(v1, v2, v3, rayHit.location))
        {
          rayHit.material = material;
          rayHit.normal = normal;

          if (PointInTriangle(v1, v2, v3, rayHit.location))
          {
            float u = ComputeUV(v1, v2, v3, rayHit.location).get(0);
            float v = ComputeUV(v1, v2, v3, rayHit.location).get(1);
            rayHit.u = (tex1.x * (1 - (u + v))) + (tex2.x * u) + (tex3.x * v);
            rayHit.v = (tex1.y * (1 - (u + v))) + (tex2.y * u) + (tex3.y * v);
          }

          if (PVector.dot(r.direction, normal) < 0)
          {
            rayHit.entry = true;
            result.add(rayHit);
          }
        }
      }
    }
    return result;
  }


  ArrayList<Float> ComputeUV(PVector v1, PVector v2, PVector v3, PVector p)
  {
    ArrayList<Float> tempArray = new ArrayList();
    PVector e = PVector.sub(v2, v1);
    PVector g = PVector.sub(v3, v1);
    PVector d = PVector.sub(p, v1);
    float denom = PVector.dot(e, e) * PVector.dot(g, g) - PVector.dot(e, g) * PVector.dot(g, e);

    float u = (PVector.dot(g, g) * PVector.dot(d, e) - PVector.dot(e, g) * PVector.dot(d, g))/denom;
    float v = (PVector.dot(e, e) * PVector.dot(d, g) - PVector.dot(e, g) * PVector.dot(d, e))/denom;

    tempArray.add(u);
    tempArray.add(v);

    return tempArray;
  }

  boolean PointInTriangle(PVector v1, PVector v2, PVector v3, PVector p)
  {
    ArrayList<Float> tempArray = new ArrayList();
    tempArray = ComputeUV(v1, v2, v3, p);

    float u = tempArray.get(0);
    float v = tempArray.get(1);

    if (u >= 0 && v >= 0 && (u+v) <= 1)
      return true;
    return false;
  }
}

class Cylinder implements SceneObject
{
  float radius;
  float height;
  Material material;
  float scale;

  Cylinder(float radius, Material mat, float scale)
  {
    this.radius = radius;
    this.height = -1;
    this.material = mat;
    this.scale = scale;
  }
  Cylinder(float radius, float height, Material mat, float scale)
  {
    this.radius = radius;
    this.height = height;
    this.material = mat;
    this.scale = scale;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    ArrayList<RayHit> result = new ArrayList<RayHit>();

    RayHit rayHit1 = new RayHit();
    RayHit rayHit2 = new RayHit();
    PVector centerTop = new PVector(0, 0, height);
    PVector centerBottom = new PVector(0, 0, 0);
    PVector normalTop = new PVector(0, 1, 0);
    PVector normalBottom = new PVector(0, -1, 0);
    boolean rayHit1InCyl = false, rayHit2InCyl = false;

    float a = sq(r.direction.x) + sq(r.direction.y);
    float b = 2 * r.origin.x * r.direction.x + 2 * r.origin.y * r.direction.y;
    float c = sq(r.origin.x) + sq(r.origin.y) - sq(radius);

    rayHit1.t = (-b + sqrt(sq(b) - 4 * a * c)) / (2 * a);
    rayHit2.t = (-b - sqrt(sq(b) - 4 * a * c)) / (2 * a);
    rayHit1.location = PVector.add(r.origin, PVector.mult(r.direction, rayHit1.t));
    rayHit2.location = PVector.add(r.origin, PVector.mult(r.direction, rayHit2.t));
    rayHit1.normal = rayHit1.location.copy().set(rayHit1.location.x, rayHit1.location.y, 0).normalize();
    rayHit2.normal = rayHit2.location.copy().set(rayHit2.location.x, rayHit2.location.y, 0).normalize();
    rayHit1.material = material;
    rayHit2.material = material;

    rayHit1.u = 0.5 + atan2(rayHit1.normal.y, rayHit1.normal.x) / TWO_PI;
    float v1Coordinate = -rayHit1.location.z / scale;
    rayHit1.v = v1Coordinate - floor(v1Coordinate);

    rayHit2.u = 0.5 + atan2(rayHit2.normal.y, rayHit2.normal.x) / TWO_PI;
    float v2Coordinate = -rayHit2.location.z / scale;
    rayHit2.v = v2Coordinate - floor(v2Coordinate);


    if (height > 0)
    {
      if (rayHit1.location.z < 0 || rayHit1.location.z > height)
        if ((PVector.dot(PVector.sub(centerTop, r.origin), normalTop) / PVector.dot(r.direction, normalTop)) >= 0 || (PVector.dot(PVector.sub(centerBottom, r.origin), normalBottom) / PVector.dot(r.direction, normalBottom)) >= 0)
          if ((sq(r.origin.x + rayHit1.t * r.direction.x) + sq(r.origin.y + rayHit1.t * r.direction.y) <= sq(radius)))
            rayHit1InCyl = true;

      if (rayHit2.location.z < 0 || rayHit2.location.z > height)
        if ((PVector.dot(PVector.sub(centerTop, r.origin), normalTop) / PVector.dot(r.direction, normalTop)) >= 0 || (PVector.dot(PVector.sub(centerBottom, r.origin), normalBottom) / PVector.dot(r.direction, normalBottom)) >= 0)
          if ((sq(r.origin.x + rayHit2.t * r.direction.x) + sq(r.origin.y + rayHit2.t * r.direction.y) <= sq(radius)))
            rayHit2InCyl = true;
    }

    if (rayHit1InCyl && !rayHit2InCyl)
    {
      rayHit1.entry = true;
      result.add(rayHit1);
    } else if (rayHit2InCyl && !rayHit1InCyl)
    {
      rayHit2.entry = true;
      result.add(rayHit2);
    } else if (rayHit1InCyl && rayHit2InCyl)
    {
      if (rayHit1.t > rayHit2.t)
      {
        rayHit2.entry = true;
        result.add(rayHit2);
        rayHit1.entry = false;
        result.add(rayHit1);
      } else
      {
        rayHit1.entry = true;
        result.add(rayHit1);
        rayHit2.entry = false;
        result.add(rayHit2);
      }
    } else if (rayHit1.t > 0 && rayHit2.t > 0)
    {
      if (rayHit1.t > rayHit2.t)
      {
        rayHit2.entry = true;
        result.add(rayHit2);
        rayHit1.entry = false;
        result.add(rayHit1);
      } else
      {
        rayHit1.entry = true;
        result.add(rayHit1);
        rayHit2.entry = false;
        result.add(rayHit2);
      }
    }
    return result;
  }
}

class Cone implements SceneObject
{
  Material material;
  float scale;

  Cone(Material mat, float scale)
  {
    this.material = mat;
    this.scale = scale;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    float a = sq(r.direction.x) + sq(r.direction.y) - sq(r.direction.z);
    float b = 2 * r.origin.x * r.direction.x + 2 * r.origin.y * r.direction.y - 2 * r.origin.z * r.direction.z;
    float c = sq(r.origin.x) + sq(r.origin.y) - sq(r.origin.z);

    return QuadricsHelper(a, b, c, material, r, scale, 1);
  }
}

class Paraboloid implements SceneObject
{
  Material material;
  float scale;

  Paraboloid(Material mat, float scale)
  {
    this.material = mat;
    this.scale = scale;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    float a = sq(r.direction.x) + sq(r.direction.y);
    float b = 2 * r.origin.x * r.direction.x + 2 * r.origin.y * r.direction.y - r.direction.z;
    float c = sq(r.origin.x) + sq(r.origin.y) - r.origin.z;

    return QuadricsHelper(a, b, c, material, r, scale, 2);
  }
}

class HyperboloidOneSheet implements SceneObject
{
  Material material;
  float scale;

  HyperboloidOneSheet(Material mat, float scale)
  {
    this.material = mat;
    this.scale = scale;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    float a = sq(r.direction.x) + sq(r.direction.y) - sq(r.direction.z);
    float b = 2 * r.origin.x * r.direction.x + 2 * r.origin.y * r.direction.y - 2 * r.origin.z * r.direction.z;
    float c = sq(r.origin.x) + sq(r.origin.y) - sq(r.origin.z) - 1;

    return QuadricsHelper(a, b, c, material, r, scale, 2);
  }
}

class HyperboloidTwoSheet implements SceneObject
{
  Material material;
  float scale;

  HyperboloidTwoSheet(Material mat, float scale)
  {
    this.material = mat;
    this.scale = scale;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    float a = sq(r.direction.x) + sq(r.direction.y) - sq(r.direction.z);
    float b = 2 * r.origin.x * r.direction.x + 2 * r.origin.y * r.direction.y - 2 * r.origin.z * r.direction.z;
    float c = sq(r.origin.x) + sq(r.origin.y) - sq(r.origin.z) + 1;

    return QuadricsHelper(a, b, c, material, r, scale, 2);
  }
}
