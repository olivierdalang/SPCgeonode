from django.contrib.auth.hashers import BasePasswordHasher, mask_hash
import hashlib, base64, os
from collections import OrderedDict
from django.utils.translation import gettext_noop as _t
from django.utils.crypto import constant_time_compare


class GeoserverDigestPasswordHasher(BasePasswordHasher):
    """
    Geoserver Digest1 hashing

    Iterations is hardcoded to 100000 (as this is what geoserver uses) and salt is prepended to the hash
    So Django's iteration and salt features don't make much sense
    """
    algorithm = "geoserver_digest"
    iterations = 100000
    salt_size = 16

    def salt(self):        
        return os.urandom(self.salt_size).replace('$','_')

    def encode(self, password, salt, iterations=None):
        # Implementation translated from https://github.com/jboss-fuse/jasypt/blob/jasypt-1_8/jasypt/src/main/java/org/jasypt/digest/StandardByteDigester.java#L943-L1009

        assert password is not None
        assert salt and '$' not in salt
        if not iterations:
            iterations = self.iterations
        
        md = hashlib.sha256()
        md.update(salt)
        md.update(password)

        digest = md.digest()
        for i in range(iterations-1):
            md = hashlib.sha256()
            md.update( digest )
            digest = md.digest()

        return "%s$%s$-$%s" % (self.algorithm, iterations, base64.b64encode(salt + digest))

    def verify(self, password, encoded):
        algorithm, iterations, _, hash = encoded.split('$', 3)
        assert algorithm == self.algorithm

        # The salt is hardcoded in the 16 first bytes, so we don't take it from the value stored in algorithm$iterations$salt$hash
        salt = base64.b64decode(hash)[0:16]

        encoded_2 = self.encode(password, salt, int(iterations))
        return constant_time_compare(encoded, encoded_2)

    def safe_summary(self, encoded):
        algorithm, iterations, _, hash = encoded.split('$', 3)
        assert algorithm == self.algorithm
        return OrderedDict([
            (_t('algorithm'), algorithm),
            (_t('iterations'), iterations),
            (_t('hash'), mask_hash(hash)),
        ])


class GeoserverPlainPasswordHasher(BasePasswordHasher):
    """
    Geoserver Plain hashing

    DO NOT USE THIS ! IT STORES THE PASSWORD IN PLAIN IN THE DATABASE !!!

    Iterations and salt don't make sense.
    """
    algorithm = "geoserver_plain"

    def salt(self):
        return "-"

    def encode(self, password, salt=None, iterations=None):
        assert password is not None
        return "%s$-$-$%s" % (self.algorithm, password)

    def safe_summary(self, encoded):
        algorithm, _, __, hash = encoded.split('$', 3)
        assert algorithm == self.algorithm
        return OrderedDict([
            (_t('algorithm'), algorithm),
            (_t('hash'), '***'),
        ])

    def verify(self, password, encoded):
        algorithm, _, _, hash = encoded.split('$', 3)
        assert algorithm == self.algorithm
        encoded_2 = self.encode(password)
        return constant_time_compare(encoded, encoded_2)
