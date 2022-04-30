import datetime
from phabstatus import delta_between_two_dates


def test_answer():
    # All weekdays
    dt1 = datetime.datetime.strptime("2022/04/14", "%Y/%m/%d")
    dt2 = datetime.datetime.strptime("2022/04/15", "%Y/%m/%d")
    assert delta_between_two_dates(dt1, dt2) == 24 * 3600

    # One of them is weekend
    dt1 = datetime.datetime.strptime("2022/04/14", "%Y/%m/%d")
    dt2 = datetime.datetime.strptime("2022/04/16", "%Y/%m/%d")
    assert delta_between_two_dates(dt1, dt2) == 2 * 24 * 3600

    dt1 = datetime.datetime.strptime("2022/04/16", "%Y/%m/%d")
    dt2 = datetime.datetime.strptime("2022/04/18", "%Y/%m/%d")
    assert delta_between_two_dates(dt1, dt2) == 2 * 24 * 3600

    dt1 = datetime.datetime.strptime("2022/04/16", "%Y/%m/%d")
    dt2 = datetime.datetime.strptime("2022/04/17", "%Y/%m/%d")
    assert delta_between_two_dates(dt1, dt2) == 24 * 3600

    # One of them is holiday
    dt1 = datetime.datetime.strptime("2022/04/29", "%Y/%m/%d")
    dt2 = datetime.datetime.strptime("2022/05/02", "%Y/%m/%d")
    assert delta_between_two_dates(dt1, dt2) == 3 * 24 * 3600

    dt1 = datetime.datetime.strptime("2022/05/02", "%Y/%m/%d")
    dt2 = datetime.datetime.strptime("2022/05/04", "%Y/%m/%d")
    assert delta_between_two_dates(dt1, dt2) == 2 * 24 * 3600

    # Spans a holiday
    dt1 = datetime.datetime.strptime("2022/04/29", "%Y/%m/%d")
    dt2 = datetime.datetime.strptime("2022/05/03", "%Y/%m/%d")
    assert delta_between_two_dates(dt1, dt2) == 24 * 3600
