# MessDeform: Hacky deformable mesh engine for Godot

## Motivation

For 2D game development is often desirable to be able to do skinned bone-based animation on characters. The Godot engine is not expected to be able to support that until the 3.0 release. It currently lacks a 2D deformable mesh node so there is no hope in being able to import animations from popular 2D animation tools and not even creating them right in it.

So currently you can only perform cut-out animation in Godot, which is good for mechanical characters like robots but not usable for organic stuff like actual people.

### Cut-out animation vs. animation powered by *MessDeform*
<img src="https://s9.postimg.io/xhty0xd5b/without_mess_deform.gif" width="256" alt="Cut-out sample"/>
<img src="https://s21.postimg.org/9dsoxez9z/with_mess_deform.gif" width="256" alt="Sample powered by MessDeform"/>

## The project

*MessDeform* is a plugin for Godot that abuses the `Polygon2D` node type trying to work with a number of them as if they formed a true 2D mesh. By doing what it achieves continuity of the character image at the joints, where the cut-out technique would disrupt them.

Also it improves `Polygon2D` triangularization so instead of building it as a triangle fan it renders a triangle strip around the baricenter for less distortion.

Obviously, *MessDeform* cannot overcome the limitations imposed by the lack of a true deformation system so its results are far from perfect. Anyway for ceratin use case it does the trick: very soft bodies, environments in which the lighting helps in hiding the distortion, etc.

Those imperfections and the the reason behind the pun in the title of the project.

## Usage

### 1. Installing/enabling plugin

Copy the *`messdeform`* directory into your project *`addons`* directory and enable the plugin in the Godot editor preferences.

### 2. Creating the character

*NOTE: This is a lot of information but, once more, having a look at how the example is assembled everything will get crystal clear.*

Your character will be composed of pieces arranged in one or more segments. In the case of the walking character you see in the sample image, there are three segments:

<table>
<tr>
<th>Segment</th><th>Pieces</th>
</tr>
<tr>
<td>Main</td><td>Head, torso, front thigh, front calf, front foot</td>
</tr>
<tr>
<td>Back leg</td><td>Back thigh, back calf, back foot</td>
</tr>
<tr>
<td>Front arm</td><td>Upper arm, lower arm, hand</td>
</tr>
<tr>
<td>Back arm</td><td>Upper arm, lower arm, hand</td>
</tr>
</table>

The important thing here is that **every piece must be created as a `MessyPolygon` (a derivation of `Polygon2D`) with four vertices, arranged in clockwise order from top-left** so the top edge goes from vertex 0 to 1 and the bottom one from 3 to 2. That doesn't mean you can only create vertical segments; you can still orient a segment in any angle as long as the 3-2 edge of a piece matches the 0-1 edge of the next.

This plugin works on the shared edge between adjacent pieces so you have to respect the segment concept. In other words, **joints involve exactly two pieces, which must have a parent-child relationship in the node hierarchy**.

Had the character view front or back instead of a side one, the arms of the legs, despite in regular tools you'd been able to set it as a whole mesh, both arms or both legs would have needed a separate segment for each.

Furthermore, **adjacent pieces cannot have different sizes at their shared edge**. In other words, for a vertical segment pieces must be perfectly stacked. For instance, when joining a thigh with a calf, the calf piece must be as wide as that of the thigh, leaving as much transparent space at the sides as needed.

As another rule, **the UVs of your polygons must match its position**. The best way of achieving this is by having all the pieces in the same texture or at least each entire segment in its own dedicated texture. Actually this is pretty natural.

#### DATA LOSS WARNING!!!

*MessDeform* needs the UVs to match the positions because it works by changing the latter to make the polygons' boundaries match. The UVs are untouched and serve for it as the original copy of the data.

### 3. Applying *MessDeform*

Wherever you set fit in your scene you have to instance a `MessyJointManager` node. Its only attribute is *Enabled* which lets you switch off the engine if for some reason you need to see your character as it is to work in cut-out mode to see something more clearly or so.

Now for every joint (shared edge between parent-child adjacent pieces) you have to add one instance of `MessyJoint` as a child of the `MessyJointManager`.

For each one you have to pick the parent and child pieces. *MessDeform* assumes the parent is the one whose 3-2 edge matches the 0-1 of the child. For any other purpuse, parentship does not matter.

If you need to invert this relationship you could check the *Inverse* option of the `MessyJoint`. In the sample project that is done for the torso-head joint. As the torso is already the parent of the thigh the only way of adding another child would be at the opposite edge but you cannot just switch parent-child nodes because the head goes on top of the torso (its 3-2 edge fits the 0-1 edge of the torso).

### 4. Adjusting weights

#### Joints

`MessyJoint`s also have a *Parent Weight* attribute you can tweak. 1 means only the parent will be deformed by this joint; 0 means the same for the child.

In many cases you'll want to leave it at 0.5 because it's the value producing less distortion. Nonetheless, for joints involving a terminal piece, like torso-head, you may get better results with values near 1. For small terminal child pieces it can be even necessary to do that so they don't degenerate and result in assertion errors about bad polygon in the Godot console.

#### Polygons

`MessyPolygon` has a weight setting for each vertex. With those you can control where the baricenter of the triangulated polygon will be. That way you can ponderate texture deformation across the polygon to reduce it on the worst cases. Furthermore, you can even keyframe these values for a fine-grained control, though not usually necessary.

## If something goes wrong

If for any reason the engine started deforming the character in strange ways and you are sure your setup is right, you can force a `MessyJointManager` to reset by selecting it in the editor and clicking the *Reset* button that will appear in the editor toolbar or by disabling and re-enabling it.

## In case of accident

If some piece stops being managed by *MessDeform* because you pick another one for a `MessyJoint` or you simply remove the joint without having reseted the character posture, you will be left with a semi-permanent deformed state.

The easiest way of recovering its original geometry is to select the ruined `MessyPolygon` and opening the UV editor (*UV* button in the editor toolbar). Then pick *Edit -> UV to Polygon*. That will serve as an effective recovery of the original data.
