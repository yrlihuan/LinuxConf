import os.path
import sys
import argparse
import multiprocessing

import exiftool

def get_exif_for_batch(batch_files):
  with exiftool.ExifTool() as et:
    metadata = et.get_metadata_batch(batch_files)

  return metadata

def main(args):
  if not os.path.exists(args.source_dir):
    raise RuntimeError('Dir does not exist! ' + args.source_dir)

  image_files = []
  if args.recursive:
    for base, dirs, files in os.walk(args.source_dir):
      for f in files:
        image_files.append(os.path.join(base, f))
  else:
    for f in os.listdir(args.source_dir):
      image_files.append(os.path.join(args.source_dir, f))

  #image_files = image_files[:4000]
  batch_size = 128

  batches = []
  for i in range(0, len(image_files), batch_size):
    batches.append(image_files[i:min(i+batch_size, len(image_files))])

  pool = multiprocessing.Pool(8)
  exif_data = pool.map(get_exif_for_batch, batches)

  files_without_exif = []
  for batch_files, batch_exif in zip(batches, exif_data):
    for f, exif in zip(batch_files, batch_exif):
      path = exif['SourceFile']
      if 'EXIF:CreateDate' in exif:
        create_date = exif['EXIF:CreateDate']
      elif 'QuickTime:CreateDate' in exif:
        create_date = exif['QuickTime:CreateDate']
      else:
        create_date = ''
        files_without_exif.append(path)

      if create_date:
        print('"{}",{}'.format(path, create_date))

  #for f in files_without_exif:
  #  print(f)

  #print(len(files_without_exif), len(image_files))

if __name__ == '__main__':
  parser = argparse.ArgumentParser()
  parser.add_argument('-s', '--source_dir', required=True, type=str)
  parser.add_argument('-r', '--recursive', default=False, action='store_true')

  args = parser.parse_args(sys.argv[1:])

  main(args)

