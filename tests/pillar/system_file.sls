linux:
  system:
    enabled: true
    file:
      /tmp/sample.txt:
        source: http://techslides.com/demos/samples/sample.txt
        source_hash: 5452459724e85b4e12277d5f8aab8fc9
      sample2.txt:
        name: /tmp/sample2.txt
        source: http://techslides.com/demos/samples/sample.txt
      test2:
        name: /tmp/test2.txt
        contents: |
          line1
          line2
        user: root
        group: root
        mode: 700
        dir_mode: 700
        encoding: utf-8
        makedirs: true