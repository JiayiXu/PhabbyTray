import argparse
import requests
import json
import datetime
import numpy as np


BASE_URL = "https://phabricator.dropboxer.net/api"
WHOAMI_URL = BASE_URL + "/user.whoami"
DIFF_SEARCH_URL = BASE_URL + "/differential.revision.search"
USER_SERACH_URL = BASE_URL + "/user.search"


def run(args):
    user = args.user
    if not user:
        user, phid = whoami(args.api_token)
    else:
        phid = search_user(args.api_token, user)

    print("user_name: {}, phid: {}".format(user, phid))
    #search_diffs_for_user(args.api_token, user, "published")

    diff_info_list = search_diffs_for_user(args.api_token, user, 'published', args.start_date, args.end_date)
    print("total diffs: {}".format(len(diff_info_list)))
    for diff in diff_info_list:
        print("{}".format(diff[0]))

    close_time = np.array([diff[2] - diff[1] for diff in diff_info_list])
    print(close_time)
    print("50 {}".format(np.percentile(close_time, 50)))
    close_time_50 = np.percentile(close_time, 50)
    close_time_75 = np.percentile(close_time, 70)
    close_time_90 = np.percentile(close_time, 90)
    print("50 percentile:{}, 70 percentile:{}, 90:{}".format(
        seconds_to_hours(close_time_50), seconds_to_hours(close_time_75), seconds_to_hours(close_time_90)))
    print("last 10:")
    for diff in diff_info_list:
        if diff[2] - diff[1] > close_time_90:
            print("{}".format(diff[0]))

def seconds_to_hours(seconds):
    return seconds / 3600.0

def search_diffs_for_user(api_token, user, status, start_date=None, end_date=None):
    data = {'api.token': api_token,
            'constraints[authorPHIDs][0]': user,
            'constraints[statuses][0]': status
    }
    if start_date:
        data['constraints[createdStart]'] = int(datetime.datetime.strptime(start_date, "%Y/%m/%d").timestamp())

    if end_date:
        data['constraints[createdEnd]'] = int(datetime.datetime.strptime(end_date, "%Y/%m/%d").timestamp())

    res = requests.post(DIFF_SEARCH_URL,
        data = data)
    assert res.status_code == 200
    response_dict = json.loads(res.text)
    diffs = response_dict['result']['data']

    return [(diff['fields']['uri'], diff['fields']['dateCreated'], diff['fields']['dateModified'])
            for diff in diffs]


def search_user(api_token, user):
    res = requests.post(USER_SERACH_URL, 
        data={'api.token': api_token, 
              'constraints[usernames][0]': user
              })
    assert res.status_code == 200
    response_dict = json.loads(res.text)
    return response_dict['result']['data'][0]['phid']


def whoami(api_token):
    res = requests.post(WHOAMI_URL, data={'api.token': api_token})
    assert res.status_code == 200
    response_dict = json.loads(res.text)
    return response_dict['result']['userName'], response_dict['result']['phid']


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Show Phab status')
    parser.add_argument('-t', '--api_token', required=True, help='Phab API token. Find it in https://phabricator.dropboxer.net/settings/user/<user_name>/page/apitokens/')
    parser.add_argument('-u', '--user', help='Query user')
    parser.add_argument('-s', '--start_date', help='Start date. yyyy/mm/dd')
    parser.add_argument('-e', '--end_date', help='End date. yyyy/mm/dd')
    args = parser.parse_args()
    run(args)
