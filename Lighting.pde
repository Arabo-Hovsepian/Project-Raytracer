class Light
{
  PVector position;
  color diffuse;
  color specular;
  Light(PVector position, color col)
  {
    this.position = position;
    this.diffuse = col;
    this.specular = col;
  }

  Light(PVector position, color diffuse, color specular)
  {
    this.position = position;
    this.diffuse = diffuse;
    this.specular = specular;
  }

  color shine(color col)
  {
    return scaleColor(col, this.diffuse);
  }

  color spec(color col)
  {
    return scaleColor(col, this.specular);
  }
}

class LightingModel
{
  ArrayList<Light> lights;
  LightingModel(ArrayList<Light> lights)
  {
    this.lights = lights;
  }
  color getColor(RayHit hit, Scene sc, PVector viewer)
  {
    color hitcolor = hit.material.getColor(hit.u, hit.v);
    color surfacecol = lights.get(0).shine(hitcolor);
    PVector tolight = PVector.sub(lights.get(0).position, hit.location).normalize();
    float intensity = PVector.dot(tolight, hit.normal);
    return lerpColor(color(0), surfacecol, intensity);
  }
}

class PhongLightingModel extends LightingModel
{
  color ambient;
  boolean withshadow;
  PhongLightingModel(ArrayList<Light> lights, boolean withshadow, color ambient)
  {
    super(lights);
    this.withshadow = withshadow;
    this.ambient = ambient;
  }
  color getColor(RayHit hit, Scene sc, PVector viewer)
  {
    color sumSPlusS = color(0, 0, 0);
    color pL = color (0, 0, 0);

    for (int i = 0; i < lights.size(); i++)
    {
      PVector toLight = PVector.sub(lights.get(i).position, hit.location).normalize();
      PVector toViewer = PVector.sub(viewer, hit.location).normalize();
      PVector origin = PVector.add(hit.location, PVector.mult(toLight, EPS));
      Ray rayRef = new Ray(origin, toLight);
      ArrayList<RayHit> hitRef = sc.root.intersect(rayRef);
      if (hitRef.isEmpty() || !withshadow)
      {
        PVector R = PVector.sub(PVector.mult(PVector.mult(hit.normal, 2), PVector.dot(hit.normal, toLight)), toLight);
        color shine = multColor(multColor(lights.get(i).shine(hit.material.getColor(hit.u, hit.v)), hit.material.properties.kd), PVector.dot(hit.normal, toLight));
        color specular = multColor(multColor(lights.get(i).spec(hit.material.getColor(hit.u, hit.v)), hit.material.properties.ks), pow(PVector.dot(toViewer, R), hit.material.properties.alpha));
        color sPlusS = addColors(shine, specular);
        sumSPlusS = addColors(sPlusS, sumSPlusS);
      }
    }
    pL = addColors(sumSPlusS, multColor(scaleColor(ambient, hit.material.getColor(hit.u, hit.v)), hit.material.properties.ka));

    return pL;
  }
}
