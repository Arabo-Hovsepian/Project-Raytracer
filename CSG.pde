import java.util.Comparator;

class HitCompare implements Comparator<RayHit>
{
  int compare(RayHit a, RayHit b)
  {
    if (a.t < b.t) return -1;
    if (a.t > b.t) return 1;
    if (a.entry) return -1;
    if (b.entry) return 1;
    return 0;
  }
}

class Union implements SceneObject
{
  SceneObject[] children;
  Union(SceneObject[] children)
  {
    this.children = children;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    ArrayList<RayHit> hits = new ArrayList<RayHit>();
    ArrayList<RayHit> hitsReal = new ArrayList<RayHit>();
    int curDepth = 0;

    for (SceneObject sc : children)
    {
      ArrayList<RayHit> tempHits = new ArrayList<RayHit>();
      tempHits.addAll(sc.intersect(r));
      if (!tempHits.isEmpty() && !tempHits.get(0).entry)
        curDepth++;

      hits.addAll(sc.intersect(r));
    }
    hits.sort(new HitCompare());

    if (!hits.isEmpty())
    {
      for (int i = 0; i < hits.size(); i++)
      {
        if (hits.get(i).entry)
        {
          curDepth++;
          if (curDepth == 1)
          {
            hitsReal.add(hits.get(i));
          }
        } else
        {
          if (curDepth == 1)
          {
            hitsReal.add(hits.get(i));
          }
          curDepth--;
        }
      }
    } else
    {
      hitsReal.clear();
    }
    return hitsReal;
  }
}

class Intersection implements SceneObject
{
  SceneObject[] children;
  Intersection(SceneObject[] children)
  {
    this.children = children;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    ArrayList<RayHit> hits = new ArrayList<RayHit>();
    ArrayList<RayHit> hitsReal = new ArrayList<RayHit>();
    int numChild = 0, curDepth = 0;

    for (SceneObject sc : children)
    {
      numChild++;

      ArrayList<RayHit> tempHits = new ArrayList<RayHit>();
      tempHits.addAll(sc.intersect(r));
      if (!tempHits.isEmpty() && !tempHits.get(0).entry)
        curDepth++;

      hits.addAll(sc.intersect(r));
    }
    hits.sort(new HitCompare());

    if (!hits.isEmpty())
    {
      for (int i = 0; i < hits.size(); i++)
      {
        if (hits.get(i).entry)
        {
          curDepth++;
          if (curDepth == numChild)
          {
            hitsReal.add(hits.get(i));
          }
        } else
        {
          if (curDepth == numChild)
          {
            hitsReal.add(hits.get(i));
          }
          curDepth--;
        }
      }
    } else
    {
      hitsReal.clear();
    }
    return hitsReal;
  }
}

class Difference implements SceneObject
{
  SceneObject a;
  SceneObject b;
  Difference(SceneObject a, SceneObject b)
  {
    this.a = a;
    this.b = b;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
    ArrayList<RayHit> hits = new ArrayList<RayHit>();
    ArrayList<RayHit> hitsReal = new ArrayList<RayHit>();
    ArrayList<RayHit> tempHits = new ArrayList<RayHit>();
    boolean in_a = false, in_b = false;

    hits.addAll(a.intersect(r));
    if (!hits.isEmpty() && !hits.get(0).entry)
      in_a = true;
    hits.forEach((n) -> n.is_a = true);  
    
    tempHits.addAll(b.intersect(r));
    if (!tempHits.isEmpty() && !tempHits.get(0).entry)
      in_b = true;
    hits.addAll(tempHits);
    
    hits.sort(new HitCompare());

    int i = 0;
    while (i < hits.size())
    {
      boolean entry = hits.get(i).entry;

      if (in_a && !in_b)
      {
        if (entry)
        {
          hits.get(i).entry = false;
          hits.get(i).normal = PVector.mult(hits.get(i).normal, -1);
        }
        hitsReal.add(hits.get(i));
      }

      if (hits.get(i).is_a && entry)
      {
        in_a = true;
      } else if (hits.get(i).is_a && !entry)
      {
        in_a = false;
      } else if (!hits.get(i).is_a && entry)
      {
        in_b = true;
      } else if (!hits.get(i).is_a && !entry)
      {
        in_b = false;
      }

      if (in_a && !in_b)
      {
        if (!entry)
        {
          hits.get(i).entry = true;
          hits.get(i).normal = PVector.mult(hits.get(i).normal, -1);
        }
        hitsReal.add(hits.get(i));
      }
      i++;
    }
    return hitsReal;
  }
}
