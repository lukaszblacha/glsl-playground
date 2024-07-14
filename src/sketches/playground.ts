import type P5 from "p5";
import { Vec2like, vec2 } from '../utils/vec';

import frag from "./shader.frag.glsl?raw";
import vert from "./shader.vert.glsl?raw";

export const sketch = (p: P5) => {
  let renderer: P5.Renderer | undefined;
  let shader: P5.Shader;

  p.setup = () => {
    p.width = 800;
    p.height = 600;
    renderer = p.createCanvas(p.width, p.height, p.WEBGL);
    shader = p.createShader(vert, frag);
    shader.setUniform("uRes", [p.width, p.height]);
    p.shader(shader);
    p.noStroke();
    const canvas_size = vec2.from();
    const cursor_start = vec2.from();
    const mouse = vec2.from();
    let pressed = false;

    const get_mouse_xy = (client_xy: Vec2like) => vec2.from(client_xy)
      .sub(cursor_start)
      .div(canvas_size)
      .mul(2)
      .mirror_y
      .add(mouse)
      .xy;

    renderer.mousePressed((e: MouseEvent) => {
      const { width, height } = (e.target as Element).getBoundingClientRect();
      canvas_size.xy = [width, height];
      cursor_start.xy = [e.clientX, e.clientY];
      pressed = true;
    });

    renderer.mouseReleased((e: MouseEvent) => {
      pressed = false;
      mouse.xy = get_mouse_xy(vec2.from([e.clientX, e.clientY]));
    });

    renderer.mouseMoved((e: MouseEvent) => {
      if (pressed) {
        const xy = get_mouse_xy([e.clientX, e.clientY]);
        requestAnimationFrame(() => {
          shader.setUniform("uMouse", xy);
        });
      }
    });
  };

  p.draw = () => {
    shader.setUniform("uTime", p.millis() / 1000);

    p.quad(-1, -1, -1, 1, 1, 1, 1, -1);
  };
};
