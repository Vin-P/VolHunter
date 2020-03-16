from os import listdir
from os.path import isfile, join
import os.path
import codecs
from shutil import copyfile


def encoding(vhfilepath, outpath):
    """
    :brief Convert to utf8 with Linux line endings

    :param vhfilepath: File path for VolHunter data
    :param outpath: File path for processing folder
    """
    for dirpath,_,filenames in os.walk(vhfilepath):
        for file_name in filenames:
            file_process = os.path.abspath(os.path.join(dirpath, file_name))
            target_file_name = outpath + file_name
            try:
                file_name = codecs.open(file_process, encoding='utf-8', errors='strict')
                #Valid utf-8
                #copy passing files
                copyfile(file_process, target_file_name)
            except UnicodeDecodeError:
                #print "invalid utf-8"
                with open(file_process, 'rb') as source_file:
                    with open(target_file_name, 'w+b') as dest_file:
                        contents = source_file.read()
                        dest_file.write(contents.decode('utf-16').encode('utf-8'))

            # replacement strings
            WINDOWS_LINE_ENDING = b'\r\n'
            UNIX_LINE_ENDING = b'\n'

            # relative or absolute file path, e.g.:
            file_path = target_file_name

            with open(file_path, 'rb') as open_file:
                content = open_file.read()

            content = content.replace(WINDOWS_LINE_ENDING, UNIX_LINE_ENDING)

            with open(file_path, 'wb') as open_file:
                open_file.write(content)
