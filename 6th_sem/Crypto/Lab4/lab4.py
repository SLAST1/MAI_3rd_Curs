#Пивницкий Д.С.
#М8о-306Б-19
import random
import urllib.request
import string

TEXT_LENGTH = 700000
TEST_NUM = 10

def commmon_letters_num(text1, text2):
    num = 0
    for ch1, ch2 in zip(text1, text2):
        if ch1 == ch2:
            num += 1

    return num

def match_perc(text1, text2):
    return commmon_letters_num(text1, text2) / len(text1)

def rand_letter():
    return random.choice(string.ascii_letters)

def rand_text(n):
    text = ''
    while len(text) < n:
        word_len = random.randint(3, 9)
        word = ''.join(rand_letter() for i in range(word_len))
        text += ' ' + word

    if len(text) > n:
        text = text[:(n - len(text))]

    return text

def rand_words(n):
    url_short_words = 'https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-usa-no-swears-short.txt'
    url_mid_words = 'https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-usa-no-swears-medium.txt'
    url_long_words = 'https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-usa-no-swears-long.txt'
    dictionary = urllib.request.urlopen(url_short_words).read().decode()\
               + urllib.request.urlopen(url_mid_words).read().decode()\
               + urllib.request.urlopen(url_long_words).read().decode()
    dictionary = dictionary.splitlines()
    text = ''
    while len(text) < n:
        text += ' ' + random.choice(dictionary)
    if len(text) > n:
        text = text[: (n - len(text))]

    return text

def comp1():
    print("Comparison 1: two meaningful text in natural language")
    url1 = 'http://www.gutenberg.org/files/1342/1342-0.txt'
    url2 = 'http://www.gutenberg.org/files/2600/2600-0.txt'
    text1 =  urllib.request.urlopen(url1).read().decode()
    text2 =  urllib.request.urlopen(url2).read().decode()
    min_len = min(len(text1), len(text2))
    text1 = text1[:min_len]
    text2 = text2[:min_len]
    print("Text length: {0}".format(min_len))
    print("Match percentage: {0}".format(match_perc(text1, text2)))

def comp2():
    print("Comparison 2: meaningful text and text from random letters")
    url1 = 'http://www.gutenberg.org/files/1342/1342-0.txt'
    text1 =  urllib.request.urlopen(url1).read().decode()
    text2 = rand_text(len(text1))
    print("Text length: {0}".format(len(text1)))
    print("Match percentage: {0}".format(match_perc(text1, text2)))

def comp3():
    print("Comparison 3: meaningful text and text from random words")
    url1 = 'http://www.gutenberg.org/files/1342/1342-0.txt'
    text1 =  urllib.request.urlopen(url1).read().decode()
    m = 0
    for i in range(TEST_NUM):
        text2 = rand_words(len(text1))
        m += match_perc(text1, text2)
    m /= TEST_NUM
    print("Text length: {0}".format(len(text1)))
    print("Match percentage: {0}".format(m))

def comp4():
    print("Comparison 4: two texts from random letters")
    m = 0
    for i in range(TEST_NUM):
        text1 = rand_text(TEXT_LENGTH)
        text2 = rand_text(TEXT_LENGTH)
        m += match_perc(text1, text2)
    m /= TEST_NUM
    print("Text length: {0}".format(len(text1)))
    print("Match percentage: {0}".format(m))

def comp5():
    print("Comparison 5: two texts from random words")
    m = 0
    for i in range(TEST_NUM):
        text1 = rand_words(TEXT_LENGTH)
        text2 = rand_words(TEXT_LENGTH)
        m += match_perc(text1, text2)
    m /= TEST_NUM
    print("Text length: {0}".format(len(text1)))
    print("Match percentage: {0}".format(m))

if __name__ == '__main__':
    comp1()
    comp2()
    comp3()
    comp4()
    comp5()