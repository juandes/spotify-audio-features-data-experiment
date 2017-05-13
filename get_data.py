import argparse
import pprint
import sys
import os
import subprocess
import json
import spotipy
import spotipy.util as util
import pandas as pd

from spotipy.oauth2 import SpotifyClientCredentials


client_credentials_manager = SpotifyClientCredentials()


def get_playlist_content(username, playlist_id, sp):
    offset = 0
    songs = []
    while True:
        content = sp.user_playlist_tracks(username, playlist_id, fields=None,
                                          limit=100, offset=offset, market=None)
        songs += content['items']
        if content['next'] is not None:
            offset += 100
        else:
            break

    with open('{}-{}'.format(username, playlist_id), 'w') as outfile:
        json.dump(songs, outfile)


def get_playlist_audio_features(username, playlist_id, sp):
    offset = 0
    songs = []
    items = []
    ids = []
    while True:
        content = sp.user_playlist_tracks(username, playlist_id, fields=None, limit=100, offset=offset, market=None)
        songs += content['items']
        if content['next'] is not None:
            offset += 100
        else:
            break

    for i in songs:
        ids.append(i['track']['id'])

    index = 0
    audio_features = []
    while index < len(ids):
        audio_features += sp.audio_features(ids[index:index + 50])
        index += 50

    features_list = []
    for features in audio_features:
        features_list.append([features['energy'], features['liveness'],
                              features['tempo'], features['speechiness'],
                              features['acousticness'], features['instrumentalness'],
                              features['time_signature'], features['danceability'],
                              features['key'], features['duration_ms'],
                              features['loudness'], features['valence'],
                              features['mode'], features['type'],
                              features['uri']])

    df = pd.DataFrame(features_list, columns=['energy', 'liveness',
                                              'tempo', 'speechiness',
                                              'acousticness', 'instrumentalness',
                                              'time_signature', 'danceability',
                                              'key', 'duration_ms', 'loudness',
                                              'valence', 'mode', 'type', 'uri'])
    df.to_csv('{}-{}.csv'.format(username, playlist_id), index=False)


def get_user_playlist(username, sp):
    playlists = sp.user_playlists(username)
    for playlist in playlists['items']:
        print("Name: {}, Number of songs: {}, Playlist ID: {} ".
              format(playlist['name'].encode('utf8'),
                     playlist['tracks']['total'],
                     playlist['id']))


def main(username, playlist):
    sp = spotipy.Spotify(client_credentials_manager=client_credentials_manager)
    print "Getting user playlist"
    get_user_playlist(username, sp)
    print "Getting playlist content"
    get_playlist_content(username, playlist, sp)
    print "Getting playlist audio features"
    get_playlist_audio_features(username, playlist, sp)


if __name__ == '__main__':
    print 'Starting...'
    parser = argparse.ArgumentParser(description='description')
    parser.add_argument('--username', help='username')
    parser.add_argument('--playlist', help='username')
    args = parser.parse_args()
    main(args.username, args.playlist)
