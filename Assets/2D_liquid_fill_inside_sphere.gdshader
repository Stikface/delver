// 2D liquid inside 'sphere' shader.

// Original Author: Mirza Beig
// Godot Implementation: RuverQ

// https://twitter.com/TheMirzaBeig
// https://www.youtube.com/@MirzaBeig

// https://twitter.com/RuverQuack

// Feel free to use this however you want.
// Modify, learn from it, copy-paste, etc...

// Original Shadertoy: https://www.shadertoy.com/view/Ds3BRN
// Extended Shadertoy: https://www.shadertoy.com/view/Ds3fRN
/*

INFO:

sdf = gradient for circle.
vB, vbA = vertical band, +animated.

fW, bW = front waves, back waves.

fA = fill animation, just a simple, constant (small) wave.
fP = fill progress, where 0.0 = center.

Set as normalized and centered (-0.5 * 2.0) mouse Y (for interactivity).
Uses mix and step in place of a bool to check if mouse button is held down.

fF, bF = front fill, back fill.

*/

shader_type canvas_item;

uniform float fill_value = 0.5;
uniform float wave_frequency = 2.0;
uniform float wave_alternation_frequency = 4.0;//alternation doesnt scroll x
uniform float wave_alternation_amplitude = 0.1;
//amplitudes are as a fraction of the whole UV height
uniform float wave_amplitude = 0.05;
uniform float idle_jiggle_amplitude = 0.05; //this moves the whole fill

void fragment() {
	//scale the whole thing to fit inside the UVs
    vec2 uv = (-UV / vec2(0.5,0.5)) + vec2(1,1);

    float
		//this offsets the entire thing?
		sdf=length(uv),
		//inner circle where the fluid is
		c=step(sdf,.85),
		//smoothstep()
        vB=smoothstep(.1,.9,sin(uv.x+(PI*.5))-.3),
		vBA=vB*sin(TIME*wave_alternation_frequency)*wave_alternation_amplitude,
		
        fW=(sin(((TIME*wave_frequency)+uv.x)*wave_frequency)*wave_amplitude)+vBA,
		bW=(sin(((TIME*-wave_frequency)+uv.x)*wave_frequency+PI)*wave_amplitude)-vBA,
		
        fA=(sin(TIME*4.)*wave_amplitude)*vB,
        
        fP=fill_value * 2.3 +(sin((TIME)*PI)*idle_jiggle_amplitude) - 1.1,
		
        fF=step(uv.y,(fA+fW)+fP)*c,
		bF=step(uv.y,(-fA+bW)+fP)*c;

    COLOR =
		vec4((step(sdf,1.)-step(sdf,.9))+
		(fF+(clamp(bF-fF,0.,1.)*.8))+
		clamp(pow((sdf+.01)*
		((1.-(fF+bF))*c),5.),0.,1.));
		
}