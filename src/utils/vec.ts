export type Vec2like = number | vec2 | number[];

function clamp(val: number, min: number, max: number) {
  return Math.max(min, Math.min(max, val));
}

function assertVec2Length(arr: number[]) {
  if (arr.length !== 2) {
    throw new Error(`Invalid vector size ${arr.length}, expected 2`);
  }
}

export class vec2 {
  private val: number[];

  static from(val: Vec2like = 0) {
    if (typeof val === 'number') {
      return new vec2(val, val);
    }
    if (val instanceof vec2) {
      return new vec2(val.x, val.y);
    }
    assertVec2Length(val);
    return new vec2(...val);
  }

  constructor(x: number = 0, y: number = 0) {
    this.xy = [x, y];
  }

  set(val: Vec2like) {
    this.xy = vec2.from(val).xy;
  }

  set x(val: number) {
    this.val[0] = val;
  }

  set y(val: number) {
    this.val[1] = val;
  }

  set xy(val: number[]) {
    assertVec2Length(val);
    this.val = val;
  }

  get x() {
    return this.val[0];
  }

  get y() {
    return this.val[1];
  }

  get xy() {
    return [this.val[0], this.val[1]];
  }

  get yx() {
    return this.xy.reverse();
  }

  sub(val: Vec2like) {
    const vec = vec2.from(val);
    return vec2.from([this.x - vec.x, this.y - vec.y]);
  }

  add(val: Vec2like) {
    const vec = vec2.from(val);
    return vec2.from([this.x + vec.x, this.y + vec.y]);
  }

  div(val: Vec2like) {
    const vec = vec2.from(val);
    return vec2.from([this.x / vec.x, this.y / vec.y]);
  }

  mul(val: Vec2like) {
    const vec = vec2.from(val);
    return vec2.from([this.x * vec.x, this.y * vec.y]);
  }

  mod(val: Vec2like) {
    const vec = vec2.from(val);
    return vec2.from([this.x % vec.x, this.y % vec.y]);
  }

  clamp(min: number, max: number) {
    return vec2.from([
      clamp(this.x, min, max),
      clamp(this.y, min, max)
    ]);
  }

  get mirror_x() {
    return this.mul([-1, 1]);
  }

  get mirror_y() {
    return this.mul([1, -1]);
  }

  toString() {
    return `vec2(${this.val.map(v => v.toFixed(2)).join(', ')})`;
  }

  valueOf() {
    return this.val;
  }
}
