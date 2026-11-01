#!/usr/bin/env python3
"""Portador del Eco modular v1: FOUR new independently-authored SVG parts.
The prior v0.2/v0.3 pixel art is NOT used as input.
Output: individual high-resolution transparent PNGs + pivot JSON + real assembly.
"""
from pathlib import Path
from io import BytesIO
import json
import cairosvg
from PIL import Image, ImageDraw

ROOT=Path("assets/player/portador_modular_v1")
SRC=ROOT/"svg_source"
PNG=ROOT/"png"
QA=Path("docs/animation")
for p in (SRC,PNG,QA):p.mkdir(parents=True,exist_ok=True)

DEFS="""<defs>
<linearGradient id="plate" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#7a747b"/><stop offset=".25" stop-color="#353640"/><stop offset=".62" stop-color="#181b25"/><stop offset="1" stop-color="#090c13"/></linearGradient>
<linearGradient id="steel" x1="0" y1="0" x2=".95" y2="1"><stop stop-color="#bbb3b0"/><stop offset=".23" stop-color="#535661"/><stop offset=".57" stop-color="#292c35"/><stop offset="1" stop-color="#12131a"/></linearGradient>
<linearGradient id="plating" x1="0" y1="0" x2="1" y2=".15"><stop stop-color="#171923"/><stop offset=".5" stop-color="#66606a"/><stop offset="1" stop-color="#131620"/></linearGradient>
<linearGradient id="crimson" x1="0" y1="0" x2=".8" y2="1"><stop stop-color="#ab384a"/><stop offset=".55" stop-color="#63182a"/><stop offset="1" stop-color="#260e1c"/></linearGradient>
<linearGradient id="leather" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#734e3b"/><stop offset=".6" stop-color="#342322"/><stop offset="1" stop-color="#1d1519"/></linearGradient>
</defs>"""
ART={
"head_helmet":"""<path d="M422 209 L436 192 448 151 460 184 473 177 492 139 495 184 518 191 534 209 552 216 538 234 527 251 507 272 464 274 439 254Z" fill="#11131c" stroke="#080a10" stroke-width="5"/>
<path d="M429 215 L451 192 460 161 465 205 480 198 490 155 494 209 514 205 524 216 505 231 459 241Z" fill="url(#plate)" stroke="#9a8b92" stroke-width="2.2"/>
<path d="M463 218 L493 210 529 220 538 225 521 240 504 255 471 254Z" fill="url(#steel)" stroke="#a89b99" stroke-width="3"/>
<path d="M467 245 L502 235 536 229 516 261 495 283 465 273 444 252Z" fill="url(#plate)" stroke="#7d747c" stroke-width="3"/>
<path d="M486 237 L529 227 517 243 495 251Z" fill="#0d0b13" stroke="#d82e43" stroke-width="2"/>
<path d="M501 240 L523 232 516 241 500 247Z" fill="#fe3e55"/><path d="M505 240 L522 236" stroke="#ffb3a1" stroke-width="2"/>
<path d="M525 241 L515 266 499 282 493 268 501 244Z" fill="url(#steel)" stroke="#100d14" stroke-width="2"/>
<path d="M446 243 L463 264 477 274 465 283 447 269Z" fill="url(#plating)" stroke="#7e747b" stroke-width="2.2"/>
<path d="M444 205 L429 225 413 221 421 240 447 238 M455 219 L466 230 481 229" fill="none" stroke="#a1a0a1" stroke-width="2.3"/>
<path d="M468 193 L477 209 472 231 485 243 478 257 M503 208 L515 223 506 237" fill="none" stroke="#ed4054" stroke-width="2.7"/>
<path d="M447 253 L461 266 M481 263 L497 268" stroke="#d3b8b3" stroke-opacity=".75" stroke-width="1.8"/>""",
"neck_guard":"""<path d="M446 254 Q463 246 493 259 L507 294 495 329 449 335 433 304Z" fill="#11131b" stroke="#0b0d13" stroke-width="3"/>
<path d="M439 278 L485 265 499 287 491 308 455 319 442 300Z" fill="url(#leather)" stroke="#7c4b51" stroke-width="3"/>
<path d="M448 268 L482 268 488 297 462 311 447 300Z" fill="url(#plate)" stroke="#a79b98" stroke-width="2.5"/>
<path d="M445 300 L486 291 501 306 489 324 447 329 437 313Z" fill="url(#plating)" stroke="#9e878a" stroke-width="2.5"/>
<path d="M450 303 L483 303 M457 316 L489 312" fill="none" stroke="#d4aaa5" stroke-opacity=".6" stroke-width="2"/>
<path d="M453 276 L463 291 456 302" fill="none" stroke="#de3b50" stroke-width="2.6"/>""",
"torso_upper":"""<path d="M408 294 Q436 280 477 287 Q515 282 541 315 L553 369 536 455 521 515 448 532 411 489 397 396Z" fill="#0d1119" stroke="#0a0c12" stroke-width="4"/>
<ellipse cx="411" cy="336" rx="25" ry="39" fill="#13141d" stroke="#73646e" stroke-width="3"/>
<ellipse cx="535" cy="340" rx="21" ry="39" fill="#13141d" stroke="#73646e" stroke-width="3"/>
<path d="M414 311 Q465 279 522 310 L537 354 518 411 509 475 482 517 441 510 411 456 407 365Z" fill="url(#plate)" stroke="#91858a" stroke-width="4"/>
<path d="M436 320 L472 303 502 321 509 358 480 394 442 371Z" fill="url(#steel)" stroke="#958b90" stroke-width="2.6"/>
<path d="M479 318 L521 320 525 355 505 388 479 394Z" fill="url(#plating)" stroke="#716f77" stroke-width="2.6"/>
<path d="M415 379 Q460 394 477 405 L514 382 522 407 491 433 459 434 417 407Z" fill="url(#steel)" stroke="#12121a" stroke-width="3"/>
<path d="M415 419 L455 443 494 436 517 413 513 445 486 468 443 463 416 446Z" fill="url(#plate)" stroke="#887a80" stroke-width="2.5"/>
<path d="M421 459 L446 480 485 484 511 456 507 487 483 503 451 505 429 484Z" fill="url(#plating)" stroke="#97868a" stroke-width="2.3"/>
<path d="M430 495 L449 515 480 518 500 502 502 526 482 544 447 536Z" fill="url(#plate)" stroke="#a09594" stroke-width="2.3"/>
<path d="M408 297 Q455 284 480 294 Q522 281 541 312 L530 334 496 326 Q463 344 421 324 L389 333 398 309Z" fill="url(#crimson)" stroke="#bd5060" stroke-width="2.5"/>
<path d="M411 327 Q461 344 505 326 L524 333 Q480 352 458 352 L419 340 399 351 401 334Z" fill="#520e23" stroke="#a2334a" stroke-width="2.3"/>
<path d="M418 302 Q466 317 524 304 M423 331 Q470 344 514 329" fill="none" stroke="#d96976" stroke-opacity=".6" stroke-width="2.2"/>
<path d="M443 355 L466 385 458 407 467 429 456 443 M489 448 L477 469 486 479 M440 470 L449 488" fill="none" stroke="#f03b51" stroke-width="2.7"/>
<path d="M416 360 L436 382 457 388 484 396 M426 445 L462 454 490 449 M437 496 L463 507" fill="none" stroke="#d3bab4" stroke-opacity=".6" stroke-width="1.9"/>
<circle cx="413" cy="360" r="3" fill="#c5b5b5"/><circle cx="521" cy="354" r="3" fill="#c5b5b5"/>""",
"pelvis_waist":"""<path d="M411 488 Q465 481 514 491 L545 506 544 553 525 601 483 632 422 617 392 553 397 508Z" fill="#0e1018" stroke="#0a0c12" stroke-width="4"/>
<path d="M398 503 L530 501 542 521 525 547 411 539Z" fill="url(#leather)" stroke="#a88f85" stroke-width="3"/>
<path d="M411 515 Q480 529 538 513" fill="none" stroke="#e1bab1" stroke-opacity=".55" stroke-width="2.4"/>
<path d="M505 504 L529 501 537 529 511 531Z" fill="url(#steel)" stroke="#bba09a" stroke-width="2.7"/>
<path d="M513 510 L524 509 528 521 515 523Z" fill="#1c1118" stroke="#bd897b" stroke-width="1.4"/>
<path d="M521 508 L523 522 517 525" stroke="#ef3a4f" stroke-width="2" fill="none"/>
<path d="M402 536 L450 536 463 568 450 609 416 612 401 574Z" fill="url(#plate)" stroke="#a89a98" stroke-width="2.8"/>
<path d="M464 538 L530 537 539 562 519 603 476 613 458 568Z" fill="url(#plating)" stroke="#9c898c" stroke-width="2.8"/>
<path d="M418 545 L441 548 449 570 438 589 421 582Z" fill="url(#steel)" stroke="#16131b" stroke-width="2"/>
<path d="M485 546 L522 547 526 565 511 588 482 593Z" fill="url(#plate)" stroke="#201a22" stroke-width="2"/>
<path d="M443 579 L471 565 467 626 454 647 441 617Z" fill="url(#crimson)" stroke="#b04151" stroke-width="2"/>
<path d="M484 584 L506 579 501 620 488 638 479 609Z" fill="#4c1627" stroke="#982f44" stroke-width="2"/>
<path d="M413 540 L434 560 429 578 M520 549 L506 565 512 584" stroke="#c5ada9" stroke-opacity=".6" stroke-width="2" fill="none"/>
<path d="M473 548 L478 563 472 585 M535 546 L525 561" stroke="#e03b4c" stroke-width="2.4" fill="none"/>
<circle cx="422" cy="516" r="2.4" fill="#b8a4a1"/><circle cx="445" cy="519" r="2.4" fill="#b8a4a1"/><circle cx="470" cy="521" r="2.4" fill="#b8a4a1"/>"""
}
PIVOTS={"head_helmet":(454,274),"neck_guard":(462,316),"torso_upper":(468,510),"pelvis_waist":(474,556)}
PARENTS={"head_helmet":"neck_guard","neck_guard":"torso_upper","torso_upper":"pelvis_waist","pelvis_waist":"hips"}
Z={"head_helmet":30,"neck_guard":10,"torso_upper":20,"pelvis_waist":40}
parts=[]
for name,body in ART.items():
    svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="800" viewBox="0 0 1000 800">{DEFS}{body}</svg>'
    (SRC/f"portador_{name}.svg").write_text(svg)
    img=Image.open(BytesIO(cairosvg.svg2png(bytestring=svg.encode(),output_width=3000,output_height=2400))).convert("RGBA")
    bbox=img.getchannel("A").getbbox()
    if bbox is None:raise ValueError(f"Empty art {name}")
    bw,bh=bbox[2]-bbox[0],bbox[3]-bbox[1]
    margin=int(max(bw,bh)*.18)
    crop=(max(0,bbox[0]-margin),max(0,bbox[1]-margin),min(img.width,bbox[2]+margin),min(img.height,bbox[3]+margin))
    clipped=img.crop(crop)
    clipped.save(PNG/f"portador_{name}.png",optimize=True)
    anchor=PIVOTS[name]
    parts.append({"id":name,"file":f"portador_{name}.png","svg_source":f"portador_{name}.svg","parent":PARENTS[name],"anchor_master":[anchor[0]*3,anchor[1]*3],"pivot_px":[anchor[0]*3-crop[0],anchor[1]*3-crop[1]],"canvas_px":list(clipped.size),"z":Z[name],"art_status":"pending_neutral_visual_review","source":"independently authored vector paths"})
    print(name,clipped.size,parts[-1]["pivot_px"])
manifest={"project":"EchoFragment","version":"Modular V1 Sprint 01","is_new_art":True,"old_rig_discarded":True,"production_method":"4 independent original SVG drawings rendered to RGBA PNG (not image cutouts)","master_canvas":[3000,2400],"parts":parts,"approval":"NOT APPROVED; neutral pose QA first"}
(ROOT/"manifest.json").write_text(json.dumps(manifest,indent=2))
scene=Image.new("RGBA",(3000,2400),(0,0,0,0))
for p in sorted(parts,key=lambda p:p["z"]):
    src=Image.open(PNG/p["file"]).convert("RGBA")
    x=p["anchor_master"][0]-p["pivot_px"][0]
    y=p["anchor_master"][1]-p["pivot_px"][1]
    scene.alpha_composite(src,(x,y))
scene.save(QA/"portador_modular_v1_core_neutral.png")
preview=Image.new("RGB",scene.size,(19,22,31))
preview.paste(scene,mask=scene.getchannel("A"))
draw=ImageDraw.Draw(preview)
draw.text((150,140),"EchoFragment | Portador del Eco Modular V1 — CORE",fill=(240,220,220))
draw.text((150,190),"4 SVG originals / 4 independent PNGs / neutral pose only",fill=(211,132,150))
for p in parts:
    x,y=p["anchor_master"]
    draw.ellipse((x-10,y-10,x+10,y+10),fill=(255,76,96))
    draw.text((x+20,y+5),p["id"],fill=(255,219,220))
preview.save(QA/"portador_modular_v1_core_review.jpg",quality=91)
print("DONE 4 PNG plus transparent assembly")
