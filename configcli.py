#!/usr/bin/env python
"""
Leverage the python ConfigParser() class for use as a commandline INI
file reader, can be used from bash to leverage all the safety in place.

See: https://docs.python.org/2/library/configparser.html

Copyright 2017 troyengel

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""
import signal
import argparse
# python2 = ConfigParser, python3 = configparser
try:
    import ConfigParser as configparser
except:
    import configparser

__version__ = "0.0.1"


def read_ini(cfgfile, section, key):
    # because we're simply printing to stdout, it really doesn't
    # matter if the file is missing, the section, the key or the
    # value - just try and get whatever is in there and print it
    # out in a very bash-esque way. Just avoid all exceptions.
    try:
        config = configparser.SafeConfigParser()
        config.read(cfgfile)
        if config.has_option(section, key):
            return config.get(section, key)
    except:
        pass

    # any error is just an empty string return
    return ""


def parse_args():
    """Argument parsing routine"""
    parser = argparse.ArgumentParser(description='ConfigCli')
    parser.add_argument('--version',
                        action='version',
                        version=__version__,
                        help='Display the version')
    parser.add_argument('-f',
                        '--file',
                        required=True,
                        dest='cfgfile',
                        help='Config file to read')
    parser.add_argument('-s',
                        '--section',
                        required=True,
                        dest='section',
                        help='Section to read')
    parser.add_argument('-k',
                        '--key',
                        required=True,
                        dest='key',
                        help='Key to read')
    return parser.parse_args()


def sigbye_handler(signal, frame):
    """Exit function triggered by caught signals"""
    sys.exit(0)


if __name__ == '__main__':
    """Main entry point for ConfigCli"""
    # register a clean shutdown for the usual signals
    signal.signal(signal.SIGINT, sigbye_handler)
    signal.signal(signal.SIGQUIT, sigbye_handler)
    signal.signal(signal.SIGTERM, sigbye_handler)

    args = parse_args()
    print(read_ini(args.cfgfile, args.section, args.key))
