{ ... }:
{
  # Make function composition easier.
  compose = f: g: x: f (g x);
}
