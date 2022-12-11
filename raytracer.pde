String input =  "data/tests/demo/demo3 (Needle Inside a Cone).json";
String output = "data/tests/demo/demo3 (Needle Inside a Cone).png";
int repeat = 0;

int iteration = 0;

// If there is a procedural material in the scene,
// loop will automatically be turned on if this variable is set
boolean doAutoloop = true;

// Animation demo:
//String input = "data/tests/demo/animation2/scene%03d.json";
//String output = "data/tests/demo/animation2/scene%03d.png";
//int repeat = 250;



RayTracer rt;

void setup() {
  size(640, 640);
  noLoop();
  if (repeat == 0)
    rt = new RayTracer(loadScene(input));
}

void draw () {
  background(255);
  if (repeat == 0)
  {
    PImage out = null;
    if (!output.equals(""))
    {
      out = createImage(width, height, RGB);
      out.loadPixels();
    }
    for (int i=0; i < width; i++)
    {
      for (int j=0; j< height; ++j)
      {
        color c = rt.getColor(i, j);
        set(i, j, c);
        if (out != null)
          out.pixels[j*width + i] = c;
      }
    }

    // This may be useful for debugging:
    // only draw a 3x3 grid of pixels, starting at (315,315)
    // comment out the full loop above, and use this
    // to find issues in a particular region of an image, if necessary
    //for (int i = 0; i< 3; ++i)
    //{
    //  for (int j = 0; j< 3; ++j)
    //    set(410+i, 265+j, rt.getColor(410+i, 265+j));
    //}

    if (out != null)
    {
      out.updatePixels();
      out.save(output);
    }
  } else
  {
    // With this you can create an animation!
    // For a demo, try:
    //    input = "data/tests/milestone3/animation1/scene%03d.json"
    //    output = "data/tests/milestone3/animation1/frame%03d.png"
    //    repeat = 100
    // This will insert 0, 1, 2, ... into the input and output file names
    // You can then turn the frames into an actual video file with e.g. ffmpeg:
    //    ffmpeg -i frame%03d.png -vcodec libx264 -pix_fmt yuv420p animation.mp4
    String inputi;
    String outputi;
    for (; iteration < repeat; ++iteration)
    {
      inputi = String.format(input, iteration);
      outputi = String.format(output, iteration);
      if (rt == null)
      {
        rt = new RayTracer(loadScene(inputi));
      } else
      {
        rt.setScene(loadScene(inputi));
      }
      PImage out = createImage(width, height, RGB);
      out.loadPixels();
      for (int i=0; i < width; i++)
      {
        for (int j=0; j< height; ++j)
        {
          color c = rt.getColor(i, j);
          out.pixels[j*width + i] = c;
          if (iteration == repeat - 1)
            set(i, j, c);
        }
      }
      out.updatePixels();
      out.save(outputi);
    }
  }
  updatePixels();
}

class Ray
{
  Ray(PVector origin, PVector direction)
  {
    this.origin = origin;
    this.direction = direction;
  }
  PVector origin;
  PVector direction;
}

// TODO: Start in this class!
class RayTracer
{
  Scene scene;

  RayTracer(Scene scene)
  {
    setScene(scene);
  }

  void setScene(Scene scene)
  {
    this.scene = scene;
  }

  color getColor(int x, int y)
  {
    PVector origin = scene.camera;
    PVector forward = scene.view;
    PVector up = new PVector(0, 0, 1);
    PVector left = PVector.mult(up.cross(forward).normalize(), tan(scene.fov / 2));
    up = PVector.mult(forward.cross(left).normalize(), tan(scene.fov / 2));

    float w = width;
    float h = height;
    float u = x*1.0/w - 0.5;
    float v = - (y*1.0/h - 0.5);
    PVector direction = PVector.add(PVector.mult(left, -u*w), PVector.add(PVector.mult(forward, w/2), PVector.mult(up, v*h)));

    Ray ray = new Ray(origin, direction.normalize());

    ArrayList<RayHit> hits = scene.root.intersect(ray);
    ArrayList<RayHit> hitsRef = new ArrayList<>();
    color finalColor = color (0, 0, 0);
    if (hits.size() > 0)
    {
      if (hits.get(0).material.properties.reflectiveness == 0 && hits.get(0).material.properties.transparency == 0)
      {
        return scene.lighting.getColor(hits.get(0), scene, ray.origin);
      } else if (hits.get(0).material.properties.transparency > 0)
      {
        PVector i = ray.direction;
        PVector N = hits.get(0).normal;
        float h1 = 1;
        float h2 = hits.get(0).material.properties.refractionIndex;
        float cosTheta1 = -PVector.dot(i, N);
        float sin2Theta2 = pow(h1/h2, 2) * (1-pow(cosTheta1, 2));
        float savedMatTraIndex = 0;
        finalColor = scene.lighting.getColor(hits.get(0), scene, ray.origin);

        if (1-sin2Theta2 < 0)
        {
          return scene.lighting.getColor(hits.get(0), scene, ray.origin);
        }

        PVector t = PVector.add(PVector.mult(i, h1/h2), PVector.mult(N, h1/h2*cosTheta1 - sqrt(1-sin2Theta2))).normalize();
        PVector originRef = PVector.add(hits.get(0).location, PVector.mult(t, EPS));
        Ray rayRef = new Ray(originRef, t);
        hitsRef = scene.root.intersect(rayRef);
        savedMatTraIndex = hits.get(0).material.properties.transparency;
        if (!hitsRef.isEmpty())
        {
          finalColor = lerpColor(finalColor, scene.lighting.getColor(hitsRef.get(0), scene, rayRef.origin), savedMatTraIndex);
        }

        while (!hitsRef.isEmpty() && hitsRef.get(0).material.properties.transparency > 0)
        {
          i = rayRef.direction;
          N = PVector.mult(hitsRef.get(0).normal, -1);
          //float temp = h1;
          //h1 = h2;
          //h2 = temp;
          cosTheta1 = -PVector.dot(i, N);
          sin2Theta2 = pow(h1/h2, 2) * (1-pow(cosTheta1, 2));
          t = PVector.add(PVector.mult(i, h1/h2), PVector.mult(N, h1/h2*cosTheta1 - sqrt(1-sin2Theta2))).normalize();
          originRef = PVector.add(hitsRef.get(0).location, PVector.mult(t, EPS));
          rayRef = new Ray(originRef, t);
          savedMatTraIndex = hitsRef.get(0).material.properties.transparency;
          hitsRef = scene.root.intersect(rayRef);
          if (!hitsRef.isEmpty())
          {
            finalColor = lerpColor(finalColor, scene.lighting.getColor(hitsRef.get(0), scene, rayRef.origin), savedMatTraIndex);
          } else
          {
            finalColor = lerpColor(finalColor, scene.background, savedMatTraIndex);
          }
        }

        if (!hitsRef.isEmpty() && hitsRef.get(0).material.properties.reflectiveness == 0)
        {
          return lerpColor(finalColor, scene.lighting.getColor(hitsRef.get(0), scene, rayRef.origin), savedMatTraIndex);
        } else if (hitsRef.isEmpty())
        {
          return lerpColor(finalColor, scene.background, savedMatTraIndex);
        }
      }

      PVector V = PVector.mult(ray.direction, -1);
      PVector N = hits.get(0).normal;
      PVector R = PVector.sub(PVector.mult(PVector.mult(N, 2), PVector.dot(N, V)), V);
      PVector originRef = PVector.add(hits.get(0).location, PVector.mult(R, EPS));
      Ray rayRef = new Ray(originRef, R);
      hitsRef = scene.root.intersect(rayRef);
      int numRef = 1;
      float savedMatRefIndex = hits.get(0).material.properties.reflectiveness;
      if (finalColor == color(0, 0, 0))
      {
        finalColor = scene.lighting.getColor(hits.get(0), scene, ray.origin);
      }

      if (!hitsRef.isEmpty())
      {
        finalColor = lerpColor(finalColor, scene.lighting.getColor(hitsRef.get(0), scene, rayRef.origin), savedMatRefIndex);
      } else
      {
        finalColor = lerpColor(finalColor, scene.background, savedMatRefIndex);
      }

      while (!hitsRef.isEmpty() && hitsRef.get(0).material.properties.reflectiveness > 0 && numRef < scene.reflections)
      {
        V = PVector.mult(rayRef.direction, -1);
        N = hitsRef.get(0).normal;
        R = PVector.sub(PVector.mult(PVector.mult(N, 2), PVector.dot(N, V)), V);
        originRef = PVector.add(hitsRef.get(0).location, PVector.mult(R, EPS));
        rayRef = new Ray(originRef, R);
        savedMatRefIndex = savedMatRefIndex * hitsRef.get(0).material.properties.reflectiveness; //<>// //<>//
        hitsRef = scene.root.intersect(rayRef);
        if (!hitsRef.isEmpty())
        {
          finalColor = lerpColor(finalColor, scene.lighting.getColor(hitsRef.get(0), scene, rayRef.origin), savedMatRefIndex);
        } else
        {
          finalColor = lerpColor(finalColor, scene.background, savedMatRefIndex);
        }
        numRef++;
      }
      return finalColor;
    }

    return scene.background;
  }
}
