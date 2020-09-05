import traceback
import unittest

class SerdeTest(unittest.TestCase):

    def test_serde(self):
        from genpy.msg import TestFillEmbedTime
        import StringIO
        test_msg = TestFillEmbedTime()
        test_msg.str_msg.data = "howdy"

        # Serialize a message
        try:
            out1 = StringIO.StringIO()
            test_msg.serialize(out1)
            out1.close()
        except Exception:
            self.fail("Failed to serialize message:\n%s" % (traceback.format_exc()))

        # Deserialize a serialized message
        try:
            out2 = StringIO.StringIO()
            test_msg.serialize(out2)
            deserd_msg = TestFillEmbedTime()
            deserd_msg.deserialize(out2.getvalue())
            out2.close()
            assert deserd_msg.str_msg.data == test_msg.str_msg.data, test_msg.str_msg.data
        except Exception:
            self.fail("Failed to deserialize message:\n%s" % (traceback.format_exc()))