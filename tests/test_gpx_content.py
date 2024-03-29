# Test en développement
# Vérifier si les waypoints des fichiers GPX sont les mêmes que dans le fichier de signalisation.xlsx

import gpxpy

# Parsing an existing file:
# -------------------------

xmlfile = "gpx/input/Signalisation_1.gpx"

gpx_file = open(xmlfile, 'r')

gpx = gpxpy.parse(gpx_file)

list_wp = []

print("Waypoints présents dans le fichier :")

for waypoint in gpx.waypoints:
    print(f'waypoint {waypoint.name} -> ({waypoint.comment})')
    list_wp.append(waypoint.name)

print("Points à traiter :")
print(list_wp)

def test_sign_in_list():
    assert "sign_01" in list_wp
