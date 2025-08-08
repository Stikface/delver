// adaptation of Mirza Beig's shader
// https://www.shadertoy.com/view/Ds3fRN

shader_type canvas_item;

uniform float fill_value : hint_range(0.0, 1.0) = 0.5;
const float ringWidth = 0.1;
const float innerCircleRadiusOffset = 0.05;
uniform float fill_oscillation_frequency = 1.0;
uniform float fill_oscillation_amplitude = 0.05; //this moves the whole fill
uniform float wave_frequency = 2.0;
uniform float wave_amplitude : hint_range(0.0, 0.7) = 0.05;
uniform float wave_phase_offset = 0.0;

uniform vec3 ringColor : source_color = vec3(1.0);
uniform vec3 frontFillInnerColor : source_color = vec3(1.0);
uniform vec3 frontFillOuterColor : source_color = vec3(0.5);
uniform float frontFillInnerStrength : hint_range(0.0, 10.0) = 4.0;
uniform bool doFrontFillGlow = false;
uniform float frontFillGlowSpeed : hint_range(0.0, 12.0) = 8.0; 
uniform float frontFillGlowIntensity : hint_range(0.0, 4.0) = 4.0; 
uniform vec3 backFillColor : source_color = vec3(0.2);

uniform vec3 fresnelColor : source_color = vec3(1.0);

uniform bool doGlow = false;
uniform float outerRingGlowSpeed : hint_range(0.0, 12.0) = 8.0;
uniform vec3 outerRingGlowColor : source_color = vec3(1.0);
uniform float outerRingGlowWidth : hint_range(0.0, 0.1) = 0.01;

void fragment() {
	// Called for every pixel the material is visible on.
	//scale the whole thing to fit inside the UVs
    vec2 uv = (-UV / vec2(0.5,0.5)) + vec2(1,1);
	
	float circleSDF = length(uv);
	
	float oneMinusRingWidth = 1.0 - ringWidth;
	
	float circleA = step(circleSDF,1.0);
	float circleB = step(circleSDF,oneMinusRingWidth);
	float ring = circleA - circleB;
	
	float fillMaskCircle = step(circleSDF, oneMinusRingWidth - innerCircleRadiusOffset);
	
	// Centered fill progress.
    //  -1.0 = bottom, 0.0 = center, 1.0 = top.
    float fillProgress = (fill_value - 0.5) * 2.0;
    fillProgress -= sin((TIME * fill_oscillation_frequency) * PI) * fill_oscillation_amplitude;
	
	const float waveAnimation = 2.0;
	float frontWavePhase = (TIME * waveAnimation) + uv.x + wave_phase_offset;
	float backWavePhase = (TIME * -waveAnimation) + uv.x + wave_phase_offset;
	frontWavePhase *= wave_frequency;
    backWavePhase *= wave_frequency;
	
	float frontWaves = sin(frontWavePhase) * wave_amplitude;
	float backWaves = sin(frontWavePhase + PI) * wave_amplitude;
	
	float frontFill = step(uv.y, frontWaves + fillProgress);
    float backFill = step(uv.y, backWaves + fillProgress);
	frontFill *= fillMaskCircle;
	backFill *= fillMaskCircle;
	backFill = clamp(backFill - frontFill, 0.0, 1.0);
	float fill = frontFill + backFill;
	float fillMask = 1.0 - fill;
    fillMask *= fillMaskCircle;
	
	// fresnel
	float fresnelOffset = (innerCircleRadiusOffset);
	float fresnel = (circleSDF + fresnelOffset) * fillMask;
	const float fresnelPower = 4.0;
	fresnel = clamp(pow(fresnel, fresnelPower), 0.0, 1.0);
	
	float frontFillGlowStrength = frontFillInnerStrength;
	if (doFrontFillGlow){
	frontFillGlowStrength += (sin(TIME * frontFillGlowSpeed) * 1.0);}
	
	float frontFillFresnel = (circleSDF + fresnelOffset) * (1.0 - fillMask);
	frontFillFresnel = clamp(pow(frontFillFresnel, frontFillGlowStrength), 0.0, frontFillGlowIntensity);
	vec3 frontFillColor = mix(frontFillInnerColor,frontFillOuterColor,frontFillFresnel);
	
	float mask = ring + fill + fresnel;

	vec3 rgb =
		(ring * ringColor) +
		(frontFill * frontFillColor) +
		(backFill * backFillColor) +
		(fresnel * fresnelColor);
	
	if (doGlow){
		//glow
		float ringGlowCircleSDF = circleSDF - 1.0;
		float outerRingGlow = ringGlowCircleSDF;
		float outerRingGlowAnimationRange = 0.4;
		float outerRingGlowPower = 1.2;
    	
    	outerRingGlowPower += (sin(TIME * outerRingGlowSpeed) * outerRingGlowAnimationRange);
    	
    	outerRingGlow = pow(outerRingGlowWidth / outerRingGlow, outerRingGlowPower);
    	outerRingGlow = clamp(outerRingGlow - fillMaskCircle, 0.0, 1.0);
		
		mask += outerRingGlow;
		rgb += (outerRingGlow * outerRingGlowColor);
	}
	
	COLOR = vec4(rgb, mask);
	
}